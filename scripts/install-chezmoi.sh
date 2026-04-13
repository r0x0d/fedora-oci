#!/usr/bin/env bash
set -euo pipefail

# Download chezmoi binary and enable systemd user services for
# automatic dotfile initialization and periodic updates.
curl -fLsS --retry 5 \
    https://github.com/twpayne/chezmoi/releases/latest/download/chezmoi-linux-amd64 \
    -o /usr/bin/chezmoi
chmod 755 /usr/bin/chezmoi

systemctl --global enable chezmoi-init.service chezmoi-update.timer
