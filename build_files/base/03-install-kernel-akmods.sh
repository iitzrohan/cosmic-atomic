#!/usr/bin/bash

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

# Remove Existing Kernel
# for pkg in kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra
# do
#     rpm --erase $pkg --nodeps
# done

# dnf5 -y install kernel-cachyos kernel-cachyos-core kernel-cachyos-modules kernel-cachyos-devel kernel-cachyos-devel-matched

# dnf5 versionlock add kernel-cachyos kernel-cachyos-core kernel-cachyos-modules kernel-cachyos-devel kernel-cachyos-devel-matched

dnf5 -y install sbsigntools openssl

KERNEL_SUFFIX=""
KERNEL_VERSION="$(rpm -qa | grep -P 'kernel-(|'"$KERNEL_SUFFIX"'-)(\d+\.\d+\.\d+)' | sed -E 's/kernel-(|'"$KERNEL_SUFFIX"'-)//')"

PUBKEY_PATH="/etc/pki/akmods/certs/public_key.der"
PRIVKEY_PATH="/etc/pki/akmods/private/private_key.priv"
CRT_PATH="/etc/pki/akmods/certs/public_key.crt"

openssl x509 -in $PUBKEY_PATH -out $CRT_PATH

EXISTING_SIGNATURES="$(sbverify --list /usr/lib/modules/$KERNEL_VERSION/vmlinuz | grep '^signature \([0-9]\+\)$' | sed 's/^signature \([0-9]\+\)$/\1/')" || true
if [[ -n $EXISTING_SIGNATURES ]]; then
for SIGNUM in $EXISTING_SIGNATURES
do
    echo "Found existing signature at signum $SIGNUM, removing..."
    sbattach --remove /usr/lib/modules/$KERNEL_VERSION/vmlinuz
done
fi
sbsign --cert $CRT_PATH --key $PRIVKEY_PATH /usr/lib/modules/$KERNEL_VERSION/vmlinuz --output /usr/lib/modules/$KERNEL_VERSION/vmlinuz
rm -rf $CRT_PATH
sbverify --list /usr/lib/modules/$KERNEL_VERSION/vmlinuz

# RPMFUSION Dependent AKMODS
dnf5 -y install \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-"$(rpm -E %fedora)".noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm
dnf5 -y install akmod-v4l2loopback

# Either successfully build and install the kernel modules, or fail early with debug output
rpm -qa |grep v4l2loopback

akmods --force --kernels "${KERNEL_VERSION}" --kmod "v4l2loopback"

dnf5 -y remove rpmfusion-free-release rpmfusion-nonfree-release

echo "::endgroup::"
