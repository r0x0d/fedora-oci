#!/usr/bin/env bash
set -euo pipefail

# System packages installed via dnf5.
dnf5 -y install \
    libvirt \
    make \
    qemu \
    qemu-kvm \
    virt-manager \
    waypipe \
    wl-clipboard \
    gh \
    fish \
    fuse-sshfs \
    clamav \
    lm_sensors
dnf5 clean all
