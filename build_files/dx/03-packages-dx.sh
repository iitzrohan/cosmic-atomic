#!/usr/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

# build list of all packages requested for inclusion
readarray -t INCLUDED_PACKAGES < <(jq -r --arg ver "$FEDORA_VERSION" '
  [
    (.all.include.dx // []),
    (.[$ver].include.dx // [])
  ] | flatten | sort | unique[]
' /tmp/packages.json)

# Install Packages
if [[ "${#INCLUDED_PACKAGES[@]}" -gt 0 ]]; then
    dnf5 -y install "${INCLUDED_PACKAGES[@]}"
else
    echo "No packages to install."
fi

# build list of all packages requested for exclusion
readarray -t EXCLUDED_PACKAGES < <(jq -r --arg ver "$FEDORA_VERSION" '
  [
    (.all.exclude.dx // []),
    (.[$ver].exclude.dx // [])
  ] | flatten | sort | unique[]
' /tmp/packages.json)

if [[ "${#EXCLUDED_PACKAGES[@]}" -gt 0 ]]; then
    readarray -t EXCLUDED_PACKAGES < <(rpm -qa --queryformat='%{NAME}\n' "${EXCLUDED_PACKAGES[@]}")
fi

# remove any excluded packages which are still present on image
if [[ "${#EXCLUDED_PACKAGES[@]}" -gt 0 ]]; then
    dnf5 -y remove "${EXCLUDED_PACKAGES[@]}"
else
    echo "No packages to remove."
fi

echo "::endgroup::"