#!/usr/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

# Install RPMS
dnf5 -y install akmod-kvmfr

# Either successfully build and install the kernel modules, or fail early with debug output
rpm -qa |grep kvmfr

KERNEL_SUFFIX=""
KERNEL_VERSION="$(rpm -qa | grep -P 'kernel-(|'"$KERNEL_SUFFIX"'-)(\d+\.\d+\.\d+)' | sed -E 's/kernel-(|'"$KERNEL_SUFFIX"'-)//')"

akmods --force --kernels "${KERNEL_VERSION}" --kmod "kvmfr"

echo "::endgroup::"
