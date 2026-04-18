# Ubuntu installer

This repository currently supports Ubuntu through `installers/ubuntu.sh`.

## Direct execution from GitHub

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/NathanRibeiroC/stateless-setup/main/install.sh)
```

## Local execution

```bash
bash install.sh
```

## Terminal defaults included

The Ubuntu installer also configures:

- `Alacritty`
- `Starship`
- `JetBrainsMono Nerd Font`
- `~/.config/alacritty/alacritty.toml`
- `~/.config/starship.toml`
- `rclone` plus a user `systemd` unit for Google Drive auto-mount at `~/GoogleDrive`

## Google Drive

The Ubuntu installer installs `rclone` and enables a user service named `gdrive-rclone.service`.

The service expects a remote named `gdrive` and mounts it to `~/GoogleDrive`. Credentials are intentionally not stored in this repository.

After installation, configure the remote once:

```bash
rclone config
```

Recommended values:

- remote name: `gdrive`
- storage type: `drive`
- scope: `drive`

Then start or restart the mount:

```bash
systemctl --user restart gdrive-rclone.service
```

Useful commands:

```bash
systemctl --user status gdrive-rclone.service
systemctl --user stop gdrive-rclone.service
systemctl --user start gdrive-rclone.service
```

## Startup Updates For Notion And Obsidian

The Ubuntu installer also creates and enables a system service named `startup-snap-refresh.service`.

At every boot, it waits for `snapd` seeding to finish and then runs:

```bash
sudo snap refresh notion-snap-reborn obsidian
```

Useful commands:

```bash
systemctl status startup-snap-refresh.service
sudo systemctl start startup-snap-refresh.service
journalctl -u startup-snap-refresh.service -n 50 --no-pager
```
