#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

if [[ ! $(command -v dnf5) ]]; then
    echo "Requires dnf5... Exiting"
    exit 1
fi

# Disable Multimedia
NEGATIVO17_MULT_PREV_ENABLED=N
if [[ -f /etc/yum.repos.d/fedora-multimedia.repo ]] && grep -q "enabled=1" /etc/yum.repos.d/fedora-multimedia.repo; then
    NEGATIVO17_MULT_PREV_ENABLED=Y
    echo "disabling negativo17-fedora-multimedia to ensure negativo17-fedora-nvidia is used"
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-multimedia.repo
fi

# Install Nvidia RPMs
rm -f /usr/share/vulkan/icd.d/nouveau_icd.*.json
ln -sf libnvidia-ml.so.1 /usr/lib64/libnvidia-ml.so

# # disable any remaining rpmfusion repos
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/rpmfusion*.repo

sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-cisco-openh264.repo

# Add Fedora Multimedia Repo
dnf config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-nvidia.repo

dnf5 install -y akmod-nvidia \
    nvidia-driver \
    libnvidia-ml \
    libnvidia-ml.i686 \
    libnvidia-fbc \
    nvidia-driver-cuda \
    nvidia-driver-cuda-libs \
    nvidia-driver-cuda-libs.i686 \
    nvidia-driver-libs \
    nvidia-driver-libs.i686 \
    nvidia-kmod-common \
    nvidia-libXNVCtrl \
    nvidia-modprobe \
    nvidia-persistenced \
    nvidia-settings \
    nvidia-xconfig \
    nvidia-vaapi-driver \
    nvidia-gpu-firmware \
    libnvidia-cfg

# Either successfully build and install the kernel modules, or fail early with debug output
rpm -qa |grep nvidia

KERNEL_SUFFIX=""
KERNEL_VERSION="$(rpm -qa | grep -P 'kernel-(|'"$KERNEL_SUFFIX"'-)(\d+\.\d+\.\d+)' | sed -E 's/kernel-(|'"$KERNEL_SUFFIX"'-)//')"

sed -i "s/^MODULE_VARIANT=.*/MODULE_VARIANT=kernel-open/" /etc/nvidia/kernel.conf

akmods --force --kernels "${KERNEL_VERSION}" --kmod "nvidia"

# Create the nvidia-modeset configuration
cat << 'EOF' > /usr/lib/modprobe.d/nvidia-modeset.conf
# Nvidia modesetting support. Set to 0 or comment to disable kernel modesetting
# support. This must be disabled in case of SLI Mosaic.

options nvidia-drm modeset=1
EOF

# we must force driver load to fix black screen on boot for nvidia desktops
sed -i 's@omit_drivers@force_drivers@g' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf
# as we need forced load, also mustpre-load intel/amd iGPU else chromium web browsers fail to use hardware acceleration
sed -i 's@ nvidia @ i915 amdgpu nvidia @g' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf

dnf config-manager setopt fedora-nvidia.enabled=0

# re-enable negativo17-mutlimedia since we disabled it
if [[ "${NEGATIVO17_MULT_PREV_ENABLED}" = "Y" ]]; then
    sed -i '0,/enabled=0/{s/enabled=0/enabled=1/}' /etc/yum.repos.d/fedora-multimedia.repo
fi

echo "::endgroup::"