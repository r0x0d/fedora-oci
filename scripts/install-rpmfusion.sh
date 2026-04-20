#!/usr/bin/env bash
set -euo pipefail

# Install RPMFusion free and non-free repositories.
# Needed for NVIDIA drivers and multimedia codecs.
dnf5 -y install \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"