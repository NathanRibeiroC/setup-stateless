# setup-stateless

Stateless Ubuntu bootstrap focused on speed and repeatability.

## One-liner (run directly from GitHub)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/NathanRibeiroC/setup-stateless/main/install-ubuntu.sh)
```

## What it installs

- Core tooling: `curl`, `wget`, `git`, `jq`
- Build tooling: `build-essential`, `make`, `zip`, `unzip`
- Dev CLI: `ripgrep`, `fd-find`, `tmux`, `tree`, `zsh`
- Python basics: `python3`, `python3-pip`, `pipx`
- Base packages: `ca-certificates`, `gnupg`, `software-properties-common`, `lsb-release`, `xclip`

## Local usage

```bash
bash install-ubuntu.sh
bash scripts/check.sh
```

## Notes

- Ubuntu only.
- Run with a user that has `sudo` access.
- Script is idempotent and safe to re-run.
