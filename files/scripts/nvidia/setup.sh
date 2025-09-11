#!/usr/bin/env bash
set -euo pipefail

# TODO(r0x0d): Remove this once https://github.com/blue-build/modules/pull/411
# get merged.

ENABLE_AKMODS_REPO() {
	akmods_repo="$(find /etc/yum.repos.d -type f -exec grep -l '\[copr:copr.fedorainfracloud.org:ublue-os:akmods\]' {} +)"
	if [[ -n "${akmods_repo}" ]]; then
		sed -i 's@enabled=0@enabled=1@g' "${akmods_repo}"
	fi
}

INSTALL_RPM_FUSION() {
	if ! rpm -q rpmfusion-free-release &>/dev/null && ! rpm -q rpmfusion-nonfree-release &>/dev/null; then
		if command -v dnf5 &>/dev/null; then
			dnf5 -y install \
				https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${OS_VERSION}.noarch.rpm \
				https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${OS_VERSION}.noarch.rpm
		elif command -v rpm-ostree &>/dev/null; then
			rpm-ostree install \
				https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${OS_VERSION}.noarch.rpm \
				https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${OS_VERSION}.noarch.rpm
		fi
		previously_not_installed_rpm_fusion=true
	else
		previously_not_installed_rpm_fusion=false
	fi
}

UNINSTALL_RPM_FUSION() {
	if "${previously_not_installed_rpm_fusion}"; then
		if command -v dnf5 &>/dev/null; then
			dnf5 -y remove rpmfusion-free-release rpmfusion-nonfree-release
		elif command -v rpm-ostree &>/dev/null; then
			rpm-ostree uninstall rpmfusion-free-release rpmfusion-nonfree-release
		fi
	fi
}

INSTALL_NVIDIA_DRIVER() {
	BASE_IMAGE_NAME=${BASE_IMAGE##*/}
	BASE_IMAGE_NAME=${BASE_IMAGE_NAME%-*}

	# Fetch Common AKMODS & Kernel RPMS
	skopeo copy --retry-times 3 docker://ghcr.io/ublue-os/akmods:"${KERNEL_BASE}"-"$(rpm -E %fedora)" dir:/tmp/akmods
	AKMODS_TARGZ=$(jq -r '.layers[].digest' </tmp/akmods/manifest.json | cut -d : -f 2)
	tar -xvzf /tmp/akmods/"$AKMODS_TARGZ" -C /tmp/
	mv /tmp/rpms/* /tmp/akmods/

	echo "Pulling akmods nvidia image"
	skopeo copy --retry-times 3 docker://ghcr.io/ublue-os/akmods-"${NVIDIA_DRIVER}":"${KERNEL_BASE}"-"$(rpm -E %fedora)" dir:/tmp/akmods-rpms

	NVIDIA_TARGZ=$(jq -r '.layers[].digest' </tmp/akmods-rpms/manifest.json | cut -d : -f 2)
	tar -xvzf /tmp/akmods-rpms/"$NVIDIA_TARGZ" -C /tmp/
	mv /tmp/rpms/* /tmp/akmods-rpms/

	# Install Nvidia RPMs
	curl -Lo /tmp/nvidia-install.sh https://raw.githubusercontent.com/ublue-os/main/main/build_files/nvidia-install.sh
	chmod +x /tmp/nvidia-install.sh
	IMAGE_NAME="${BASE_IMAGE_NAME}" RPMFUSION_MIRROR="" /tmp/nvidia-install.sh
	rm -f /usr/share/vulkan/icd.d/nouveau_icd.*.json
	ln -sf libnvidia-ml.so.1 /usr/lib64/libnvidia-ml.so

	KARGS_D="/usr/lib/bootc/kargs.d"
	BLUEBUILD_NVIDIA_TOML="${KARGS_D}/00-bluebuild-nvidia-kargs.toml"

	# Create kargs folder if doesn't exist
	mkdir -p "${KARGS_D}"
	echo 'kargs = ["rd.driver.blacklist=nouveau", "modprobe.blacklist=nouveau", "nvidia-drm.modeset=1", "initcall_blacklist=simpledrm_platform_driver_init"]' >>"${BLUEBUILD_NVIDIA_TOML}"
}

INSTALL_NVIDIA=true
NVIDIA_DRIVER="nvidia-open"
KERNEL_BASE="main"

INSTALL_PATH=("${INSTALL[@]/#/\/tmp/rpms/kmods/*}")
INSTALL_PATH=("${INSTALL_PATH[@]/%/*.rpm}")
INSTALL_STR=$(echo "${INSTALL_PATH[*]}" | tr -d '\n')

# Universal Blue switched from RPMFusion to negativo17 repos
# WL & V4L2Loopback akmods currently require RPMFusion repo, so we temporarily install then uninstall it

echo "Installing akmods"

if [[ $INSTALL_NVIDIA == true ]]; then
	echo "Installing nvidia driver: $NVIDIA_DRIVER"
	INSTALL_NVIDIA_DRIVER
fi
