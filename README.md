Bazzite Cosmic Images

Custom bootc images that combine Bazzite's gaming optimizations with Cosmic desktop environment.

## Commands

### bazzite-cosmic
```bash
sudo bootc switch ghcr.io/vehicoule/bazzite-cosmic:latest
```

### bazzite-cosmic-nvidia
```bash
sudo bootc switch ghcr.io/vehicoule/bazzite-cosmic-nvidia:latest
```

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
