# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /

# Base Image - will be overridden by build arg
ARG BASE_IMAGE=ghcr.io/ublue-os/bazzite-dx:latest
FROM ${BASE_IMAGE}

# Re-declare ARG to make it visible in this build stage
ARG BASE_IMAGE

# Set variant based on base image name
ARG VARIANT=cosmic
ENV VARIANT=${VARIANT}

RUN mkdir -p /var/lib/nix && \
    mkdir -p /nix && \
    chmod 0755 /nix && \
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm --no-start-daemon

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh && \
    ostree container commit

ENV PATH="${PATH}:/usr/local/bin:/nix/var/nix/profiles/default/bin"

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
