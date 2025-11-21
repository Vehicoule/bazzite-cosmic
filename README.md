Bazzite Cosmic Images

Custom bootc images that combine Bazzite's gaming optimizations with Cosmic desktop environment.

## Installation

### Using bootc (Recommended)

#### bazzite-cosmic
```bash
sudo bootc switch ghcr.io/vehicoule/bazzite-cosmic:latest
```

#### bazzite-cosmic-nvidia
```bash
sudo bootc switch ghcr.io/vehicoule/bazzite-cosmic-nvidia:latest
```

### Using rpm-ostree

#### bazzite-cosmic
```bash
sudo rpm-ostree rebase ostree-image-signed:ghcr.io/vehicoule/bazzite-cosmic:latest
```

#### bazzite-cosmic-nvidia
```bash
sudo rpm-ostree rebase ostree-image-signed:ghcr.io/vehicoule/bazzite-cosmic-nvidia:latest
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
