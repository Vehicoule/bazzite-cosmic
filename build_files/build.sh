#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# Remove xwaylandvideobridge package
dnf5 remove -y xwaylandvideobridge

# Gets the mandatory packages installed in kde-desktop and removes them.
dnf5 group info kde-desktop | \
    sed -n '/^Mandatory packages\s*:/,/^\(Default\|Optional\) packages\s*:/ {
        /^\(Default\|Optional\) packages\s*:/q  # Quit if we hit Default/Optional header
        s/^.*:[[:space:]]*//p
    }' | \
    xargs dnf5 remove -y

# Clean up package cache
dnf5 clean all && \
rm -rf /var/cache/dnf/*

# Install Cosmic desktop environment
dnf5 group install -y cosmic-desktop cosmic-desktop-apps

# Clean up package cache again
dnf5 clean all && \
rm -rf /var/cache/dnf/*

# Install additional Cosmic desktop environment packages
dnf5 install -y @cosmic-desktop-environment
dnf5 clean all && \
rm -rf /var/cache/dnf/*

# Other useful packages
dnf5 install -y \
    neovim \
    ncdu \
    NetworkManager-tui

# Enable Cosmic greeter and disable default display manager
systemctl disable display-manager && systemctl enable cosmic-greeter.service -f

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket
