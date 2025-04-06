#!/usr/bin/bash

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

dnf5 -y remove akmods

# Setup Systemd
systemctl enable rpm-ostree-countme.service
systemctl enable tailscaled.service
systemctl enable dconf-update.service
systemctl enable uupd.timer
systemctl enable rpm-ostreed-automatic.timer
systemctl enable ublue-system-setup.service
systemctl enable ublue-guest-user.service
systemctl --global enable ublue-user-setup.service
systemctl --global enable podman-auto-update.timer
systemctl enable check-sb-key.service

#Disable autostart behaviour
rm -f /etc/xdg/autostart/solaar.desktop

#Add the Flathub Flatpak remote and remove the Fedora Flatpak remote
flatpak remote-add --system --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Disable all COPRs and RPM Fusion Repos
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-multimedia.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/tailscale.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/charm.repo
dnf5 -y copr disable ublue-os/packages
dnf5 -y copr disable ublue-os/staging
dnf5 -y copr disable che/nerd-fonts
dnf5 -y copr disable phracek/PyCharm
dnf5 -y copr disable ryanabx/cosmic-epoch

sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-cisco-openh264.repo
for i in /etc/yum.repos.d/rpmfusion-*; do
    sed -i 's@enabled=1@enabled=0@g' "$i"
done

echo "::endgroup::"
