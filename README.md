# Silverblue


These are my customized versions of universal blue images for my needs.

Occaisionally, I will build beta versions around Fedora Major Release time.

## Tags

### Desktop Images

These images are aimed for desktop use. All of them are based on latest fedora official upstream image.

Every image is built from silverblue.

All images have zfs support. Nvidia Images have nvidia included as well.

These add in the following: Docker, Incus, and Steam plus different editors.

- silverblue
- silverblue-nvidia-open
- silverblue-dx
- silverblue-dx-nvidia-open

## How to Install

### Desktop Images

ISO's for Desktop Images are built using an action and uploaded as an artifact. The artifacts are linked in the releases for download. They are zipped.

For the Latest ISOs:
https://github.com/iitzrohan/silverblue/actions/workflows/build-isos.yml

Note artifacts are removed after 90 days though ISOs are refreshed weekly.

### Rebasing

You can rebase to an **silverblue** image using the following:

```console
$ sudo bootc switch --enforce-container-sigpolicy ghcr.io/iitzrohan/silverblue:TAG
```

Replace TAG with the specified image.

## Verification

All images in this repo are signed with sigstore's cosign. You can verify the signatures by running the following command

```console
$ cosign verify --key "https://raw.githubusercontent.com/iitzrohan/silverblue/refs/heads/main/cosign.pub" "ghcr.io/iitzrohan/silverblue:TAG
```

Again replace the TAG with the specified image

## DIY

This repo was build on the [Universal Blue Image Template](https://github.com/ublue-os/image-template).

It is possible to build all images and ISOs locally using the provided `Justfile` with `just`.