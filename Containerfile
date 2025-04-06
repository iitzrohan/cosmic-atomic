ARG BASE_IMAGE_NAME
ARG FEDORA_VERSION
ARG SOURCE_ORG="${SOURCE_ORG:-fedora-ostree-desktops}"
ARG BASE_IMAGE="quay.io/${SOURCE_ORG}/${BASE_IMAGE_NAME}"

FROM scratch AS ctx
COPY / /

## bluefin image section
FROM ${BASE_IMAGE}:${FEDORA_VERSION} AS base

ARG BASE_IMAGE_NAME
ARG FEDORA_VERSION
ARG IMAGE_NAME
ARG IMAGE_VENDOR
ARG KERNEL
ARG VERSION

# Build, cleanup, commit.
RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/build_files/shared/build-base.sh

## bluefin-dx developer edition image section
FROM base AS dx

ARG BASE_IMAGE_NAME
ARG FEDORA_VERSION
ARG IMAGE_NAME
ARG IMAGE_VENDOR
ARG KERNEL
ARG VERSION

# Build, Clean-up, Commit
RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/build_files/shared/build-dx.sh
