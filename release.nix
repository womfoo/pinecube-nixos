{ nixpkgs ? <nixpkgs>, system ? "armv7l-linux" }:

let
  evalNixos = configuration: import "${nixpkgs}/nixos" {
    inherit system configuration;
  };
  conf = import ./sd-image.nix;
in { iso = (evalNixos conf).config.system.build.sdImage; }
