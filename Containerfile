ARG BASE_IMAGE=quay.io/fedora-ostree-desktops/kinoite
ARG BASE_VERSION=44

FROM ${BASE_IMAGE}:${BASE_VERSION}

ARG VARIANT=amd

# Build scripts
COPY scripts/ /tmp/scripts/

# RPMFusion repositories (needed for NVIDIA drivers)
RUN /tmp/scripts/install-rpmfusion.sh

# NVIDIA drivers from RPMFusion (nvidia variant only)
RUN /tmp/scripts/install-nvidia.sh "${VARIANT}"

# System overlay files (container policies, signing keys, toolbox config)
COPY files/system/ /

# DNF packages
RUN /tmp/scripts/setup-dnf.sh

# Flatpak first-boot configuration
COPY files/flatpak/user-flatpak-setup /usr/bin/user-flatpak-setup
COPY files/flatpak/user-flatpak-setup.service /usr/lib/systemd/user/user-flatpak-setup.service
COPY files/flatpak/user-flatpak-setup.timer /usr/lib/systemd/user/user-flatpak-setup.timer
COPY files/flatpak/user-flatpak-install.list /usr/share/fedora-oci/flatpaks/user/install
RUN chmod +x /usr/bin/user-flatpak-setup && \
    systemctl --global enable user-flatpak-setup.timer

# Systemd services
RUN systemctl enable systemd-timedated.service && \
    systemctl enable systemd-timesyncd

# Chezmoi dotfiles
COPY files/chezmoi/chezmoi-init.service /usr/lib/systemd/user/chezmoi-init.service
COPY files/chezmoi/chezmoi-update.service /usr/lib/systemd/user/chezmoi-update.service
COPY files/chezmoi/chezmoi-update.timer /usr/lib/systemd/user/chezmoi-update.timer
RUN /tmp/scripts/install-chezmoi.sh

# Final cleanup
RUN /tmp/scripts/cleanup-dnf.sh && \
    rm -rf /tmp/scripts
