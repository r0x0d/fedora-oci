#!/usr/bin/env bash
set -euo pipefail

# Install NVIDIA drivers from RPMFusion and build kernel modules.
#
# akmods needs kernel-devel matching the image kernel (not the host kernel),
# and its %posttrans scriptlet fails in containers, so we skip scripts and
# run the kmod build manually.

VARIANT="${1:-amd}"

if [ "${VARIANT}" != "nvidia" ]; then
    echo "Skipping NVIDIA driver installation (variant=${VARIANT})"
    exit 0
fi

KERNEL_VERSION=$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')
echo "Building NVIDIA drivers for kernel ${KERNEL_VERSION}"

dnf5 -y install "kernel-devel-${KERNEL_VERSION}"
dnf5 -y --setopt=tsflags=noscripts install \
    akmod-nvidia \
    xorg-x11-drv-nvidia \
    libva-nvidia-driver
akmods --force --kernels "${KERNEL_VERSION}"
dnf5 clean all

# Blacklist nouveau and enable nvidia-drm.modeset on boot
mkdir -p /usr/lib/bootc/kargs.d
cat > /usr/lib/bootc/kargs.d/00-nvidia.toml <<'TOML'
kargs = ["rd.driver.blacklist=nouveau", "modprobe.blacklist=nouveau", "nvidia-drm.modeset=1"]
TOML
