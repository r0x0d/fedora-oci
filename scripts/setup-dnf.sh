#!/usr/bin/env bash
set -euo pipefail

# Remove set of packages that are present in the original ostree image
#
# * firefox is present, but it is causing a lot of problems with codecs
#   (especially if we are targeting rawhide releases). To avoid that, we are
#   switching to use firefox in flatpak
dnf remove -y firefox

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