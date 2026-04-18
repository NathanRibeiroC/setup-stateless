[CmdletBinding()]
param(
  [string]$DistroName = "Ubuntu",
  [string]$LinuxUser
)

$ErrorActionPreference = "Stop"

function Write-Setup {
  param([string]$Message)
  Write-Host "[setup:wsl] $Message"
}

function Test-IsAdministrator {
  $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = New-Object Security.Principal.WindowsPrincipal($identity)
  return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Resolve-LinuxUser {
  param([string]$RequestedUser)

  $candidate = $RequestedUser
  if ([string]::IsNullOrWhiteSpace($candidate)) {
    $candidate = $env:USERNAME
  }

  $candidate = $candidate.ToLowerInvariant() -replace '[^a-z0-9_-]', ''
  if ([string]::IsNullOrWhiteSpace($candidate)) {
    $candidate = "nathan"
  }
  if ($candidate -match '^[0-9]') {
    $candidate = "u$candidate"
  }
  if ($candidate -notmatch '^[a-z_][a-z0-9_-]*$') {
    throw "Invalid Linux username after sanitization: $candidate"
  }

  return $candidate
}

function Convert-WindowsPathToWsl {
  param([Parameter(Mandatory = $true)][string]$Path)

  $resolved = [System.IO.Path]::GetFullPath($Path)
  $normalized = $resolved -replace '\\', '/'

  if ($normalized -match '^(?<drive>[A-Za-z]):/(?<rest>.*)$') {
    $drive = $Matches['drive'].ToLowerInvariant()
    $rest = $Matches['rest']
    return "/mnt/$drive/$rest"
  }

  throw "Unsupported path for WSL path conversion: $resolved"
}

function Quote-Bash {
  param([Parameter(Mandatory = $true)][string]$Value)
  return "'" + $Value.Replace("'", "'""'""'") + "'"
}

function Invoke-Wsl {
  param(
    [Parameter(Mandatory = $true)][string[]]$Arguments,
    [switch]$AllowFailure
  )

  & wsl.exe @Arguments
  if (-not $AllowFailure -and $LASTEXITCODE -ne 0) {
    throw "wsl.exe $($Arguments -join ' ') failed with exit code $LASTEXITCODE."
  }
}

function Get-InstalledDistros {
  $output = & wsl.exe --list --quiet 2>$null
  if ($LASTEXITCODE -ne 0) {
    return @()
  }

  return $output |
    ForEach-Object { $_.Trim() } |
    Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
}

if (-not (Test-IsAdministrator)) {
  throw "Run this script from an elevated PowerShell window (Run as Administrator)."
}

$ResolvedLinuxUser = Resolve-LinuxUser -RequestedUser $LinuxUser
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$WslRepoRoot = Convert-WindowsPathToWsl -Path $RepoRoot.Path

Write-Setup "Using distro '$DistroName' and Linux user '$ResolvedLinuxUser'."

$installedDistros = Get-InstalledDistros
if ($installedDistros -notcontains $DistroName) {
  Write-Setup "Installing $DistroName through WSL..."
  & wsl.exe --install --distribution $DistroName --no-launch
  $installExitCode = $LASTEXITCODE

  if ($installExitCode -eq 3010) {
    throw "WSL requested a Windows reboot. Reboot the machine and rerun this script."
  }
  if ($installExitCode -ne 0) {
    throw "WSL install failed with exit code $installExitCode."
  }
} else {
  Write-Setup "$DistroName is already installed. Reusing the existing distro."
}

Write-Setup "Ensuring WSL 2 defaults are applied..."
Invoke-Wsl -Arguments @("--set-default-version", "2") -AllowFailure
Invoke-Wsl -Arguments @("--set-version", $DistroName, "2")
Invoke-Wsl -Arguments @("--set-default", $DistroName)

try {
  Write-Setup "Initializing the distro as root..."
  Invoke-Wsl -Arguments @("--distribution", $DistroName, "--user", "root", "--", "bash", "-lc", "true")
} catch {
  throw "The distro is not ready yet. If WSL was enabled for the first time, reboot Windows and rerun this script. $($_.Exception.Message)"
}

$rootBootstrap = @"
set -euo pipefail

if ! id -u $ResolvedLinuxUser >/dev/null 2>&1; then
  useradd -m -s /bin/bash $ResolvedLinuxUser
fi

usermod -aG sudo $ResolvedLinuxUser
install -d -m 0755 -o $ResolvedLinuxUser -g $ResolvedLinuxUser /home/$ResolvedLinuxUser/.config
install -d -m 0755 -o $ResolvedLinuxUser -g $ResolvedLinuxUser /home/$ResolvedLinuxUser/.local/bin

cat > /etc/sudoers.d/90-$ResolvedLinuxUser-setup-stateless <<'EOF'
$ResolvedLinuxUser ALL=(ALL) NOPASSWD:ALL
EOF

chmod 0440 /etc/sudoers.d/90-$ResolvedLinuxUser-setup-stateless
"@

Write-Setup "Creating or reusing the Linux user and granting passwordless sudo for bootstrap..."
Invoke-Wsl -Arguments @("--distribution", $DistroName, "--user", "root", "--", "bash", "-lc", $rootBootstrap)

$quotedRepoRoot = Quote-Bash -Value $WslRepoRoot
$quotedLinuxUser = Quote-Bash -Value $ResolvedLinuxUser
$linuxBootstrap = "cd $quotedRepoRoot && WSL_SETUP_TARGET_USER=$quotedLinuxUser bash install.sh"

Write-Setup "Running the stateless bootstrap inside Ubuntu WSL..."
Invoke-Wsl -Arguments @("--distribution", $DistroName, "--user", $ResolvedLinuxUser, "--", "bash", "-lc", $linuxBootstrap)

Write-Setup "Restarting WSL so /etc/wsl.conf changes take effect..."
Invoke-Wsl -Arguments @("--shutdown")

Write-Setup "Bootstrap complete."
Write-Setup "Open '$DistroName' or run 'wsl -d $DistroName' to start the configured environment."
