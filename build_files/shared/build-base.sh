#!/usr/bin/bash

set -eoux pipefail

echo "::group:: Copy Files"

mkdir -p /var/roothome

# Copy Files to Container
cp /ctx/packages.json /tmp/packages.json
rsync -rvK /ctx/system_files/shared/ /
PRIVKEY_PATH="/etc/pki/akmods/private/private_key.priv"
rsync -rvK /ctx/certs/private_key.priv "$PRIVKEY_PATH"
echo "::endgroup::"

# Generate image-info.json
/ctx/build_files/base/00-image-info.sh

# Get COPR Repos
/ctx/build_files/base/02-install-copr-repos.sh

# Install Kernel and Akmods
/ctx/build_files/base/03-install-kernel-akmods.sh

# Install Nvidia
if [[ "${IMAGE_NAME}" =~ nvidia-open ]]; then
    /ctx/build_files/base/04-nvidia-install.sh
fi

# Install Additional Packages
/ctx/build_files/base/04-packages.sh

# Install Overrides and Fetch Install
/ctx/build_files/base/05-override-install.sh

# Base Image Changes
/ctx/build_files/base/07-base-image-changes.sh

# Get Firmare for Framework
/ctx/build_files/base/08-firmware.sh

## late stage changes

# Systemd and Remove Items
/ctx/build_files/base/17-cleanup.sh

# Run workarounds for lf (Likely not needed)
/ctx/build_files/base/18-workarounds.sh

# Regenerate initramfs
/ctx/build_files/base/19-initramfs.sh

# Clean Up
echo "::group:: Cleanup"
/ctx/build_files/shared/clean-stage.sh
echo "::endgroup::"
