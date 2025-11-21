Bazzite Cosmic Images

Custom bootc images that combine Bazzite's gaming optimizations with Cosmic desktop environment.

## Commands

### bazzite-cosmic
```bash
sudo bootc switch ghcr.io/<username>/bazzite-cosmic:latest
```

### bazzite-cosmic-nvidia
```bash
sudo bootc switch ghcr.io/<username>/bazzite-cosmic-nvidia:latest
```

## Setup

1. Fork this repository
2. Enable GitHub Actions
3. Create signing key: `COSIGN_PASSWORD="" cosign generate-key-pair`
4. Add `cosign.key` as `SIGNING_SECRET` to repository secrets
5. Wait for builds, then switch to your image

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
