# Ubuntu WSL installer

This repository supports Ubuntu running inside WSL through two layers:

- `installers/wsl-ubuntu.ps1` on Windows
- `installers/wsl-ubuntu.sh` inside the Ubuntu distro

## When to use this flow

Use this when you are provisioning a fresh Windows machine and want WSL + Ubuntu + the Linux CLI environment ready in one pass.

## PowerShell entrypoint

Run from an elevated PowerShell session on Windows, from the root of this repository:

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\installers\wsl-ubuntu.ps1 -LinuxUser nathan
```

Optional parameters:

- `-DistroName Ubuntu` to choose a specific Ubuntu distro name exposed by `wsl --list --online`
- `-LinuxUser nathan` to control the Linux username created or reused inside the distro

## What the Windows bootstrap does

- Installs WSL and the requested Ubuntu distro when needed
- Sets WSL 2 as the default backend and the chosen Ubuntu distro as default
- Creates or reuses the requested Linux user
- Grants passwordless `sudo` to that user for bootstrap speed
- Runs `bash install.sh` inside Ubuntu WSL
- Restarts WSL at the end so `/etc/wsl.conf` changes take effect

If Windows reports that a reboot is required because WSL was just enabled, reboot Windows and rerun the same PowerShell command.

## What the Ubuntu WSL installer does

- Installs CLI packages for development (`git`, `ripgrep`, `tmux`, `zsh`, `neovim`, `pipx`, `rclone`, etc.)
- Installs `nvm` + latest Node.js
- Installs `mise`
- Installs and configures `starship`
- Writes `/etc/wsl.conf` with:

```ini
[boot]
systemd=true

[user]
default=<your-linux-user>
```

- Bootstraps LazyVim if `~/.config/nvim` does not already exist

## Validation

Inside Ubuntu WSL:

```bash
bash scripts/check.sh
```

`install.sh` already runs the validation automatically.
