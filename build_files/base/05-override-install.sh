#!/usr/bin/bash

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

dnf5 -y swap --repo=fedora OpenCL-ICD-Loader ocl-icd

dnf5 -y install \
    ublue-os-luks \
    ublue-os-udev-rules

OVERRIDES=(
    "libva"
    "intel-gmmlib"
    "intel-vpl-gpu-rt"
    "intel-mediasdk"
    "libva-intel-media-driver"
    "mesa-dri-drivers"
    "mesa-filesystem"
    "mesa-libEGL"
    "mesa-libGL"
    "mesa-libgbm"
    "mesa-va-drivers"
    "mesa-vulkan-drivers"
)

for override in "${OVERRIDES[@]}"; do
    dnf5 swap -y --repo='fedora-multimedia' \
        "$override" "$override"
    dnf5 versionlock add "$override"
done

# Disable DKMS support in gnome-software
if [[ "$FEDORA_VERSION" -ge "41" && "$IMAGE_NAME" =~ "silverblue" ]]; then
    dnf5 remove -y \
        gnome-software-rpm-ostree
    dnf5 swap -y \
        --repo=copr:copr.fedorainfracloud.org:ublue-os:staging \
        gnome-software gnome-software
    dnf5 versionlock add gnome-software
fi

# Starship Shell Prompt
curl --retry 3 -Lo /tmp/starship.tar.gz "https://github.com/starship/starship/releases/latest/download/starship-x86_64-unknown-linux-gnu.tar.gz"
tar -xzf /tmp/starship.tar.gz -C /tmp
install -c -m 0755 /tmp/starship /usr/bin
# shellcheck disable=SC2016
echo 'eval "$(starship init bash)"' >> /etc/bashrc

# Automatic wallpaper changing by month
HARDCODED_RPM_MONTH="12"
sed -i "/picture-uri/ s/${HARDCODED_RPM_MONTH}/$(date +%m)/" "/usr/share/glib-2.0/schemas/zz0-bluefin-modifications.gschema.override"
glib-compile-schemas /usr/share/glib-2.0/schemas

# Register Fonts
fc-cache -f /usr/share/fonts/ubuntu
fc-cache -f /usr/share/fonts/inter

echo "::endgroup::"
