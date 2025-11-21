# 🚀 Bazzite Cosmic Images

<div align="center">

![Bazzite Cosmic](https://img.shields.io/badge/Bazzite-Cosmic-blue?style=for-the-badge&logo=fedora)
![Cosmic Desktop](https://img.shields.io/badge/Cosmic-Desktop-purple?style=for-the-badge&logo=pop-os)
![Bootc](https://img.shields.io/badge/Bootc-Ready-green?style=for-the-badge)

</div>

This repository builds custom [bootc](https://github.com/bootc-dev/bootc) images that combine the gaming and development optimizations of [Bazzite](https://github.com/ublue-os/bazzite) with the modern [Cosmic](https://github.com/pop-os/cosmic-epoch) desktop environment. These images replace the default KDE desktop with Cosmic while preserving Bazzite's hardware support and gaming features.

## ✨ Features

- 🎮 **Gaming Optimized** - Built on Bazzite DX with all gaming enhancements
- 🖥️ **Modern Desktop** - Latest Cosmic desktop environment with Wayland compositor
- 🔧 **Developer Ready** - Includes development tools and utilities out of the box
- 📦 **Package Manager** - Nix directory structure for advanced package management
- 🎯 **GPU Support** - Optimized for both AMD and NVIDIA hardware
- 🚀 **Performance Tuned** - Btrfs filesystem and performance optimizations

## 🎯 Available Images

### 📦 Base Variant
<details>
<summary><strong>bazzite-cosmic</strong> - Bazzite DX with Cosmic desktop</summary>

Perfect for general use, development, and gaming without proprietary NVIDIA drivers.

```bash
sudo bootc switch ghcr.io/<username>/bazzite-cosmic:latest
```

**Includes:**
- Cosmic Desktop Environment
- Development Tools (Neovim, Git, Zed)
- System Utilities (htop, btop, ncdu)
- Gaming Support (Gamemode)
- Multimedia Tools (VLC, ffmpeg)
- GPU Control (LACT for AMD)

</details>

### 🎮 NVIDIA Variant  
<details>
<summary><strong>bazzite-cosmic-nvidia</strong> - Bazzite DX NVIDIA with Cosmic desktop</summary>

Optimized for NVIDIA GPUs with proprietary drivers and CUDA support.

```bash
sudo bootc switch ghcr.io/<username>/bazzite-cosmic-nvidia:latest
```

**Includes everything from base variant plus:**
- NVIDIA proprietary drivers
- CUDA support
- NVIDIA settings and control tools
- GPU persistence and fallback services

</details>

## 🛠️ Quick Start

### Prerequisites
- A GitHub Account
- A machine running a bootc image (Bazzite, Bluefin, Aurora, or Fedora Atomic)
- Experience with CLI tools

### Installation Steps

1. **🍴 Fork this repository** to your GitHub account
2. **⚙️ Enable GitHub Actions** in your fork's Settings → Actions tab
3. **🔑 Set up signing key** (see detailed instructions below)
4. **🚀 Wait for builds** to complete in Actions tab
5. **💻 Switch to your image** using one of the commands above

## 🔐 Container Signing Setup

Container signing is **required** for security. Follow these steps:

### Generate Keys
```bash
COSIGN_PASSWORD="" cosign generate-key-pair
```

### Add to GitHub Secrets
1. Go to your repository → Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Name: `SIGNING_SECRET`
4. Paste contents of `cosign.key` (not `cosign.pub`!)
5. Save

> ⚠️ **Never commit `cosign.key` to your repository!**

## 🏗️ Build System

This repository uses a sophisticated matrix build strategy:

- **Matrix Strategy**: Automatically builds both variants in parallel
- **Variant Detection**: Build script adapts based on VARIANT environment variable
- **Conflict Resolution**: Excludes Firefox to avoid dependency conflicts
- **COPR Integration**: Installs additional tools from community repositories
- **Service Management**: Proper display manager and GPU service configuration

## 📚 Repository Contents

### [Containerfile](./Containerfile)
Multi-stage build with BASE_IMAGE and VARIANT support for flexible base image selection.

### [build.sh](./build_files/build.sh)
Comprehensive build script that:
- Removes conflicting packages (Firefox exclusion)
- Installs Cosmic desktop environment
- Adds development and gaming tools
- Configures system services properly

### [.github/workflows/build.yml](./.github/workflows/build.yml)
GitHub Actions matrix workflow that builds both variants automatically with proper artifacthub integration.

### [Justfile](./Justfile)
Local development commands for building and testing images:
```bash
just build-all                    # Build both variants locally
just build bazzite-cosmic latest    # Build specific variant
```

## 💬 Community & Support

- [Universal Blue Forums](https://universal-blue.discourse.group/) - Community discussions
- [Universal Blue Discord](https://discord.gg/WEu6BdFEtp) - Real-time chat support
- [bootc Documentation](https://github.com/bootc-dev/bootc/discussions) - bootc-specific issues
- [Cosmic Desktop](https://github.com/pop-os/cosmic-epoch) - Desktop environment issues

## 🙏 Acknowledgments

- [Universal Blue](https://universal-blue.org/) - Base Bazzite system and build infrastructure
- [System76](https://system76.com/) - Cosmic desktop environment development
- [Fedora Project](https://fedoraproject.org/) - Base packages and repositories

---

<div align="center">

**⭐ If you find this useful, give it a star!**

</div>

# Repository Contents

## Repository Contents

## Containerfile

The [Containerfile](./Containerfile) defines the operations used to customize the selected image. This file uses a `BASE_IMAGE` build argument to allow matrix builds for different variants. It works exactly like a regular podman Containerfile. For reference, please see the [Podman Documentation](https://docs.podman.io/en/latest/Introduction.html).

## build.sh

The [build.sh](./build_files/build.sh) file is called from your Containerfile and performs the main customization work:
- Removes KDE desktop components from Bazzite DX base
- Installs Cosmic desktop environment and applications
- Configures Cosmic greeter as the default display manager
- Adds useful development utilities

## build.yml

The [build.yml](./.github/workflows/build.yml) Github Actions workflow creates your custom OCI images using a matrix strategy and publishes them to the Github Container Registry (GHCR). It automatically builds both `bazzite-cosmic` and `bazzite-cosmic-nvidia` variants from their respective base images.

# Building Disk Images

This template provides configuration for creating disk images (ISO, qcow, raw) for your custom Cosmic images which can be used to directly install onto your machines.

## Local Disk Image Building

You can build disk images locally using the Justfile commands:

```bash
# Build QCOW2 image for virtual machines
just build-qcow2

# Build ISO image for installation
just build-iso

# Build RAW image for direct disk writing
just build-raw
```

## Configuration Files

- [image.toml](./image.toml) - Configuration for disk images with 20GB minimum root partition
- [iso.toml](./iso.toml) - Configuration for ISO installer with kickstart post-install script

## Setting Up ISO Builds

To create ISO installers, you'll need to:
1. Update the `ghcr.io/yourrepo/yourimage:latest` reference in `iso.toml` to point to your built image
2. Use the Justfile commands or GitHub Actions to build the ISO
3. The resulting ISO will be available in the `output/` directory or as GitHub Actions artifacts

The ISO includes a kickstart script that automatically switches to your custom Cosmic image during installation, providing a seamless setup experience.

# Artifacthub

This template comes with the necessary tooling to index your image on [artifacthub.io](https://artifacthub.io). Use the `artifacthub-repo.yml` file at the root to verify yourself as the publisher. This is important to you for a few reasons:

- The value of artifacthub is it's one place for people to index their custom images, and since we depend on each other to learn, it helps grow the community. 
- You get to see your pet project listed with the other cool projects in Cloud Native.
- Since the site puts your README front and center, it's a good way to learn how to write a good README, learn some marketing, finding your audience, etc. 

[Discussion Thread](https://universal-blue.discourse.group/t/listing-your-custom-image-on-artifacthub/6446)

# Justfile Documentation

The `Justfile` contains various commands and configurations for building and managing container images and virtual machine images using Podman and other utilities.
To use it, you must have installed [just](https://just.systems/man/en/introduction.html) from your package manager or manually. It is available by default on all Universal Blue images.

## Environment Variables

- `image_name`: The name of the image (default: "image-template").
- `default_tag`: The default tag for the image (default: "latest").
- `bib_image`: The Bootc Image Builder (BIB) image (default: "quay.io/centos-bootc/bootc-image-builder:latest").

## Building The Image

### `just build`

Builds a container image using Podman.

```bash
just build $target_image $tag
```

Arguments:
- `$target_image`: The tag you want to apply to the image (default: `$image_name`).
- `$tag`: The tag for the image (default: `$default_tag`).

## Building and Running Virtual Machines and ISOs

The below commands all build QCOW2 images. To produce or use a different type of image, substitute in the command with that type in the place of `qcow2`. The available types are `qcow2`, `iso`, and `raw`.

### `just build-qcow2`

Builds a QCOW2 virtual machine image.

```bash
just build-qcow2 $target_image $tag
```

### `just rebuild-qcow2`

Rebuilds a QCOW2 virtual machine image.

```bash
just rebuild-vm $target_image $tag
```

### `just run-vm-qcow2`

Runs a virtual machine from a QCOW2 image.

```bash
just run-vm-qcow2 $target_image $tag
```

### `just spawn-vm`

Runs a virtual machine using systemd-vmspawn.

```bash
just spawn-vm rebuild="0" type="qcow2" ram="6G"
```

## File Management

### `just check`

Checks the syntax of all `.just` files and the `Justfile`.

### `just fix`

Fixes the syntax of all `.just` files and the `Justfile`.

### `just clean`

Cleans the repository by removing build artifacts.

### `just lint`

Runs shell check on all Bash scripts.

### `just format`

Runs shfmt on all Bash scripts.

## Additional resources

For additional driver support, ublue maintains a set of scripts and container images available at [ublue-akmod](https://github.com/ublue-os/akmods). These images include the necessary scripts to install multiple kernel drivers within the container (Nvidia, OpenRazer, Framework...). The documentation provides guidance on how to properly integrate these drivers into your container image.

## Community Examples

These are images derived from this template or similar Universal Blue templates. Reference them when building your image!

- [m2Giles' OS](https://github.com/m2giles/m2os)
- [bOS](https://github.com/bsherman/bos)
- [Homer](https://github.com/bketelsen/homer/)
- [Amy OS](https://github.com/astrovm/amyos)
- [VeneOS](https://github.com/Venefilyn/veneos)
- [Bazzite-based Cosmic Images](https://github.com/r-dson/bazzite-based-cosmic-nvidia) - Inspiration for this template
