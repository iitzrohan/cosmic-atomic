#!/usr/bin/bash

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

# Remove signing key
CRT_PATH="/etc/pki/akmods/certs/public_key.crt"
PRIVKEY_PATH="/etc/pki/akmods/private/private_key.priv"
rm -f $CRT_PATH
rm -f $PRIVKEY_PATH

# Remove tmp files and everything in dirs that make bootc unhappy
rm -rf /tmp/* || true
rm -rf /usr/etc
rm -rf /boot && mkdir /boot

shopt -s extglob
rm -rf /var/!(cache)
rm -rf /var/cache/!(libdnf5)

# Make sure /var/tmp is properly created
mkdir -p /var/tmp
chmod -R 1777 /var/tmp

# bootc/ostree checks
bootc container lint

ostree container commit

echo "::endgroup::"
