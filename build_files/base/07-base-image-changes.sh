#!/usr/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

# Hide Desktop Files. Hidden removes mime associations
for file in htop nvtop gnome-system-monitor; do
     if [[ -f "/usr/share/applications/$file.desktop" ]]; then
         sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nHidden=true@g' /usr/share/applications/"$file".desktop
     fi
 done

echo "::endgroup::"
