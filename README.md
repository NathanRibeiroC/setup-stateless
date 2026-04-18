# stateless-setup

Stateless Linux bootstrap focused on speed and repeatability.

> Recommended next step: add versioned VS Code configuration files (for example, workspace settings, extensions list, and keybindings) to this repository.

## TODOs

- Ensure `tmux` is installed in our stateless setup.

## Prerequisites

Before running the installer, make sure your GitHub access is configured from the terminal:

1. Configure an SSH key and add it to GitHub.
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
gh auth login
gh ssh-key add ~/.ssh/id_ed25519.pub --title "$(hostname)-$(date +%F)"
```
2. Configure a GPG key and add it to GitHub for signed commits.
```bash
gpg --full-generate-key
gpg --list-secret-keys --keyid-format LONG
gpg --armor --export <YOUR_KEY_ID> | gh gpg-key add -
```
3. Ensure GitHub CLI authentication is active.
```bash
gh auth status
```

## Windows / WSL bootstrap

For a fresh Windows machine, clone this repository on Windows and run the WSL bootstrap from an elevated PowerShell session:

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\installers\wsl-ubuntu.ps1 -LinuxUser nathan
```

What this does:

- Installs WSL 2 and the `Ubuntu` distro if they are not present yet
- Creates your Linux user and grants passwordless `sudo` for bootstrap speed
- Runs `bash install.sh` inside Ubuntu WSL
- Writes `/etc/wsl.conf` with `systemd=true` and sets the default WSL user

If Windows asks for a reboot because WSL was enabled for the first time, reboot and rerun the same PowerShell command.

## Linux one-liner (run directly from GitHub)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/NathanRibeiroC/stateless-setup/main/install.sh)
```

If `curl` is not installed yet (fresh Ubuntu), run:

```bash
sudo apt update && sudo apt install -y curl
bash <(curl -fsSL https://raw.githubusercontent.com/NathanRibeiroC/stateless-setup/main/install.sh)
```

## Current support

- `ubuntu` (desktop/server Ubuntu)
- `ubuntu-wsl` (Ubuntu running inside WSL on Windows)
- `fedora` (planned)
- `gentoo` (planned)

## Installers layout

- `install.sh` (distribution dispatcher)
- `installers/ubuntu.sh` (Ubuntu desktop/server implementation)
- `installers/wsl-ubuntu.sh` (Ubuntu-on-WSL implementation)
- `installers/wsl-ubuntu.ps1` (Windows bootstrapper for WSL + Ubuntu + Linux bootstrap)
- `installers/fedora.sh` (future)
- `installers/gentoo.sh` (future)

## Installed tools (Ubuntu)

- Core CLI: `curl`, `wget`, `git`, `jq`, `ripgrep`, `fd-find`, `tmux`, `tree`, `zsh`, `xclip`, `nvim`
- Build/tooling: `build-essential`, `make`, `zip`, `unzip`
- Python: `python3`, `python3-pip`, `pipx`
- JavaScript/Node: `nvm` + latest `node` and `npm`
- Runtime manager: `mise` (installed to `~/.local/bin/mise`)
- Base system packages: `ca-certificates`, `gnupg`, `lsb-release`, `software-properties-common`, `snapd`
- Desktop apps: `code`, `google-chrome-stable`, `brave-browser`, `bitwarden`, `libreoffice`, `notion-snap-reborn` (snap), `obsidian` (snap)
- Cloud sync: `rclone` with a user `systemd` unit for Google Drive mounting at `~/GoogleDrive`
- Startup automation: a system `systemd` unit refreshes `notion-snap-reborn` and `obsidian` on each boot
- Editor setup: LazyVim starter in `~/.config/nvim` (if no existing Neovim config is present)
- Terminal setup: `alacritty`, `starship`, `JetBrainsMono Nerd Font`, Alacritty theme in `~/.config/alacritty/alacritty.toml`, prompt theme in `~/.config/starship.toml`

## Installed tools (Ubuntu WSL)

- Core CLI: `curl`, `wget`, `git`, `jq`, `ripgrep`, `fd-find`, `tmux`, `tree`, `zsh`, `neovim`
- Build/tooling: `build-essential`, `make`, `zip`, `unzip`
- Python: `python3`, `python3-pip`, `pipx`
- JavaScript/Node: `nvm` + latest `node` and `npm`
- Runtime manager: `mise` (installed to `~/.local/bin/mise`)
- Shell setup: `starship`, `~/.config/starship.toml`, `~/.bashrc` entries for `~/.local/bin`, `nvm`, and prompt init
- WSL defaults: `/etc/wsl.conf` with `systemd=true` and the configured default user
- Cloud sync: `rclone`
- Editor setup: LazyVim starter in `~/.config/nvim` (if no existing Neovim config is present)

## Local usage

```bash
bash install.sh
```

`install.sh` auto-detects when it is running inside WSL and switches to the WSL-specific installer. It also runs `scripts/check.sh` automatically after installation.

## Post-install validation

Run the full validation:

```bash
bash scripts/check.sh
```

Run install (validation is automatic at the end):

```bash
bash install.sh
```

Show only failed/missing checks:

```bash
bash scripts/check.sh 2>&1 | rg "Missing|failed" -i
```

## Notes

- Only Ubuntu and Ubuntu-on-WSL are currently implemented.
- Run with a user that has `sudo` access.
- Script is idempotent and safe to re-run.
- Google Drive credentials are not versioned. After install, run `rclone config`, create a remote named `gdrive`, and restart `gdrive-rclone.service`.
- Notion and Obsidian already support snap auto-refresh, but this setup also forces a boot-time refresh check through `startup-snap-refresh.service`.
- The WSL bootstrap intentionally configures passwordless `sudo` for the chosen Linux user so a fresh Windows machine can be provisioned without interactive Linux password prompts.
- WSL-specific details are documented in [docs/wsl-ubuntu.md](./docs/wsl-ubuntu.md). Desktop Ubuntu details stay in [docs/ubuntu.md](./docs/ubuntu.md).

## License

This project is licensed under the MIT License. See [LICENSE](./LICENSE).
