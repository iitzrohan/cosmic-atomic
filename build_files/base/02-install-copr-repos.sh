#!/usr/bin/bash

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

# Add Cosmic Repo
dnf5 -y copr enable ryanabx/cosmic-epoch

# Add Packages repo
dnf5 -y copr enable ublue-os/packages

# Add staging repo
dnf5 -y copr enable ublue-os/staging

# Add Nerd Fonts Repo
dnf5 -y copr enable che/nerd-fonts

# Add Fedora Multimedia Repo
dnf config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-multimedia.repo
# Set higher priority
dnf5 config-manager setopt fedora-multimedia.priority=90

echo "::endgroup::"
