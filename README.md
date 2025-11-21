# Bazzite Cosmic Images

This repository builds custom [bootc](https://github.com/bootc-dev/bootc) images that combine the gaming and development optimizations of [Bazzite](https://github.com/ublue-os/bazzite) with the modern [Cosmic](https://github.com/pop-os/cosmic-epoch) desktop environment. These images replace the default KDE desktop with Cosmic while preserving Bazzite's hardware support and gaming features.

# Community

If you have questions about this template after following the instructions, try the following spaces:
- [Universal Blue Forums](https://universal-blue.discourse.group/)
- [Universal Blue Discord](https://discord.gg/WEu6BdFEtp)
- [bootc discussion forums](https://github.com/bootc-dev/bootc/discussions) - This is not an Universal Blue managed space, but is an excellent resource if you run into issues with building bootc images.

# How to Use

To get started on your first bootc image, simply read and follow the steps in the next few headings.
If you prefer instructions in video form, TesterTech created an excellent tutorial, embedded below.

[![Video Tutorial](https://img.youtube.com/vi/IxBl11Zmq5w/0.jpg)](https://www.youtube.com/watch?v=IxBl11Zmq5wE)

## Step 0: Prerequisites

These steps assume you have the following:
- A Github Account
- A machine running a bootc image (e.g. Bazzite, Bluefin, Aurora, or Fedora Atomic)
- Experience installing and using CLI programs

## Step 1: Preparing the Template

### Step 1a: Copying the Template

Select `Use this Template` on this page. You can set the name and description of your repository to whatever you would like, but all other settings should be left untouched.

Once you have finished copying the template, you need to enable the Github Actions workflows for your new repository.
To enable the workflows, go to the `Actions` tab of the new repository and click the button to enable workflows.

### Step 1b: Cloning the New Repository

Here I will defer to the much superior GitHub documentation on the matter. You can use whichever method is easiest.
[GitHub Documentation](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository)

Once you have the repository on your local drive, proceed to the next step.

## Step 2: Initial Setup

### Step 2a: Creating a Cosign Key

Container signing is important for end-user security and is enabled on all Universal Blue images. By default the image builds *will fail* if you don't.

First, install the [cosign CLI tool](https://edu.chainguard.dev/open-source/sigstore/cosign/how-to-install-cosign/#installing-cosign-with-the-cosign-binary)
With the cosign tool installed, run inside your repo folder:

```bash
COSIGN_PASSWORD="" cosign generate-key-pair
```

The signing key will be used in GitHub Actions and will not work if it is password protected.

> [!WARNING]
> Be careful to *never* accidentally commit `cosign.key` into your git repo. If this key goes out to the public, the security of your repository is compromised.

Next, you need to add the key to GitHub. This makes use of GitHub's secret signing system.

<details>
    <summary>Using the Github Web Interface (preferred)</summary>

Go to your repository settings, under `Secrets and Variables` -> `Actions`
![image](https://user-images.githubusercontent.com/1264109/216735595-0ecf1b66-b9ee-439e-87d7-c8cc43c2110a.png)
Add a new secret and name it `SIGNING_SECRET`, then paste the contents of `cosign.key` into the secret and save it. Make sure it's the .key file and not the .pub file. Once done, it should look like this:
![image](https://user-images.githubusercontent.com/1264109/216735690-2d19271f-cee2-45ac-a039-23e6a4c16b34.png)
</details>
<details>
<summary>Using the Github CLI</summary>

If you have the `github-cli` installed, run:

```bash
gh secret set SIGNING_SECRET < cosign.key
```
</details>

### Available Images

This repository builds two variants of Bazzite Cosmic images:

<details>
<summary>

**bazzite-cosmic**: Bazzite DX with Cosmic desktop environment
</summary>

```bash
sudo bootc switch ghcr.io/<username>/bazzite-cosmic:latest
```

</details>

<details>
<summary>

**bazzite-cosmic-nvidia**: Bazzite DX NVIDIA with Cosmic desktop environment and NVIDIA proprietary drivers
</summary>

```bash
sudo bootc switch ghcr.io/<username>/bazzite-cosmic-nvidia:latest
```

</details>

### What's Included

These images include:
- Cosmic desktop environment with modern Wayland compositor
- Base Bazzite DX features (development tools, gaming optimizations, hardware support)
- NVIDIA driver support (on nvidia variant)
- Development tools and utilities (neovim, ncdu, NetworkManager-tui)
- Cosmic greeter for a polished login experience

## Step 2b: Base Images

This repository uses a matrix build strategy to automatically build both variants from their respective base images:
- `ghcr.io/ublue-os/bazzite-dx:latest` → `bazzite-cosmic`
- `ghcr.io/ublue-os/bazzite-dx-nvidia:latest` → `bazzite-cosmic-nvidia`

The base images are configured in the GitHub Actions workflow and can be modified there if needed.

### Step 2c: Changing Names

Change the first line in the [Justfile](./Justfile) to your image's name.

To commit and push all the files changed and added in step 2 into your Github repository:
```bash
git add Containerfile Justfile cosign.pub
git commit -m "Initial Setup"
git push
```
Once pushed, go look at the Actions tab on your Github repository's page.  The green checkmark should be showing on the top commit, which means your new image is ready!

## Step 3: Switch to Your Image

From your bootc system, run the following command substituting in your Github username and desired variant:

For the base version:
```bash
sudo bootc switch ghcr.io/<username>/bazzite-cosmic:latest
```

For the NVIDIA version:
```bash
sudo bootc switch ghcr.io/<username>/bazzite-cosmic-nvidia:latest
```

This should queue your image for the next reboot, which you can do immediately after the command finishes. You have officially set up your custom Cosmic image! See the following section for an explanation of the important parts of the template for customization.

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
