#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
# Treat unset variables as an error.
# Exit on errors within pipes.
set -ouex pipefail

# Function to log messages with a timestamp for better tracking
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

# Function to handle errors by logging them and exiting the script
handle_error() {
    log "ERROR: $1"
    exit 1
}

# Function to clean up space aggressively
cleanup_space() {
    log "Cleaning up disk space..."
    dnf5 clean all || true
    rm -rf /var/cache/dnf/* || true
    rm -rf /tmp/* || true
    rm -rf /var/tmp/* || true
    journalctl --vacuum-time=1h || true
}

# Get base image from build argument (set by Containerfile)
BASE_IMAGE="${BASE_IMAGE:-ghcr.io/ublue-os/bazzite-dx:latest}"
VARIANT="${VARIANT:-cosmic}"
log "Starting Bazzite Cosmic build process with base image: $BASE_IMAGE"
log "Building variant: $VARIANT"

if [[ "${VARIANT}" == "cosmic" || "${VARIANT}" == "cosmic-nvidia" ]]; then

# --- Section 0: Remove Conflicting Packages ---
log "Removing conflicting packages..."

# Remove XWayland video bridge (conflicts with Cosmic)
dnf5 remove -y xwaylandvideobridge || log "Warning: xwaylandvideobridge not found or already removed"

# Remove KDE/Plasma desktop packages if present from base image
# Get mandatory packages from kde-desktop group and remove them
if dnf5 group info kde-desktop &>/dev/null; then
    dnf5 group info kde-desktop | \
        sed -n '/^Mandatory packages\s*:/,/^\(Default\|Optional\) packages\s*:/ {
            /^\(Default\|Optional\) packages\s*:/q
            s/^.*:[[:space:]]*//p
        }' | \
        xargs dnf5 remove -y || log "Warning: Failed to remove some KDE packages"
fi

# Clean up after package removal
dnf5 clean all && rm -rf /var/cache/dnf/*

log "Conflicting packages removal completed"

# --- Section 1: Install Cosmic Desktop and Essential Tools in Single Layer ---
log "Installing Cosmic desktop environment and essential tools..."

# Install everything in fewer operations to reduce layers, excluding Firefox to avoid conflicts
dnf5 install -y --exclude=firefox @cosmic-desktop-environment \
    neovim ncdu gamemode git curl wget htop btop ffmpeg vlc || handle_error "Failed to install core packages"

# Clean up immediately after major installation
cleanup_space

# --- Section 2: Install COPR Applications ---
log "Installing applications from COPR repositories..."

# Install Zed editor
if dnf5 copr enable -y che/zed; then
    dnf5 install -y zed && dnf5 copr disable -y che/zed
    log "Zed editor installed successfully"
else
    log "Warning: Failed to enable che/zed COPR repository"
fi

# Install LACT (AMD GPU control tool)
if dnf5 copr enable -y ilyaz/LACT; then
    dnf5 install -y lact && dnf5 copr disable -y ilyaz/LACT
    log "LACT installed successfully"
else
    log "Warning: Failed to enable ilyaz/LACT COPR repository"
fi

# --- Section 3: NVIDIA Variant Specific Packages ---
if [[ "${VARIANT}" == "cosmic-nvidia" ]]; then
    log "Installing NVIDIA-specific packages for cosmic-nvidia variant..."
    
    # Install NVIDIA packages in single operation
    dnf5 install -y nvidia-driver nvidia-settings nvidia-smi akmod-nvidia xorg-x11-drv-nvidia-cuda || log "Warning: Failed to install some NVIDIA packages"
    log "NVIDIA packages installation completed"
fi

# --- Section 4: Final Cleanup ---
cleanup_space

# --- Section 6: Install Determinate Nix ---
log "Installing Nix ..."
curl -L https://github.com/DavHau/nix-portable/releases/latest/download/nix-portable-$(uname -m) > /usr/local/bin/nix-portable
chmod +x /usr/local/bin/nix-portable

# Create symlinks for common nix command
ln -sf /usr/local/bin/nix-portable /usr/local/bin/nix
ln -sf /usr/local/bin/nix-portable /usr/local/bin/nix-shell
ln -sf /usr/local/bin/nix-portable /usr/local/bin/nix-run

# Test the installation
log "Testing Nix Portable installation..."
/usr/local/bin/nix-portable nix run nixpkgs#hello --version || log "Warning: Nix test failed"

# Add Nix to PATH for this build session
export PATH="${PATH}:/nix/var/nix/profiles/default/bin"
log "Determinate Nix installation completed"

# --- Section 7: Configure System Services ---
log "Configuring system services..."

# Disable other display managers to prevent conflicts with Cosmic's greeter
systemctl disable display-manager || log "Warning: Failed to disable display-manager"
systemctl disable gdm || log "Warning: gdm service not found or already disabled"
systemctl disable sddm || log "Warning: sddm service not found or already disabled"

# Enable Cosmic display manager, LACT daemon, and Podman socket
systemctl enable cosmic-greeter || handle_error "Failed to enable cosmic-greeter"
systemctl enable lactd || handle_error "Failed to enable lactd"
systemctl enable podman.socket || handle_error "Failed to enable podman.socket"

# Enable Nix daemon for multi-user support
systemctl enable nix-daemon || handle_error "Failed to enable nix-daemon"

# NVIDIA variant specific services
if [[ "${VARIANT}" == "cosmic-nvidia" ]]; then
    log "Configuring NVIDIA-specific services..."
    systemctl enable nvidia-persistenced || log "Warning: Failed to enable nvidia-persistenced"
    systemctl enable nvidia-fallback || log "Warning: Failed to enable nvidia-fallback"
fi

fi

# --- Section 8: Final Cleanup ---
cleanup_space

# --- Final Summary ---
log "Bazzite Cosmic build completed successfully!"
log "Base Image: $BASE_IMAGE"
log "Variant: $VARIANT"
log "Installed components:"
log "  - Cosmic Desktop Environment"
log "  - Determinate Nix Package Manager"
log "  - Development Tools (Git, Neovim, Zed)"
log "  - System Utilities (htop, btop, ncdu, etc.)"
log "  - Multimedia Tools (VLC, ffmpeg)"
log "  - Gaming Support (Gamemode)"
log "  - GPU Control (LACT)"

if [[ "${VARIANT}" == "cosmic-nvidia" ]]; then
    log "  - NVIDIA Drivers and Support"
fi
