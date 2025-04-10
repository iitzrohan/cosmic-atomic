#!/usr/bin/bash

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

dnf5 -y remove akmods

if rpm -q docker-ce >/dev/null; then
     systemctl enable docker.socket
 fi
systemctl enable podman.socket
systemctl enable swtpm-workaround.service
systemctl enable libvirt-workaround.service
systemctl enable bluefin-dx-groups.service

dnf5 -y copr disable ublue-os/akmods
dnf5 -y copr disable ublue-os/packages
dnf5 -y copr disable atim/ubuntu-fonts
dnf5 -y copr disable hikariknight/looking-glass-kvmfr
dnf5 -y copr disable gmaglione/podman-bootc
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/vscode.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/docker-ce.repo
dnf5 -y copr disable phracek/PyCharm
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-cisco-openh264.repo

for i in /etc/yum.repos.d/rpmfusion-*; do
    sed -i 's@enabled=1@enabled=0@g' "$i"
done

echo "::endgroup::"
