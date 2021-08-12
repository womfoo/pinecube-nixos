#!/usr/bin/env bash

nix-build "<nixpkgs/nixos>" \
    -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/c21ba4f7bb4a3d621eb1d187e6b5e816bb85380c.tar.gz \
    -I nixos-config=./sd-image.nix \
    -A config.system.build.sdImage
