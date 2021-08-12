{ config, lib, pkgs, ... }:

# This module adds system-level workarounds when cross-compiling.
# These workarounds are only expected to be implemented for the *basic* build.
# That is `nix-build ./default.nix`, without additional configuration.
let
  isCross =
    config.nixpkgs.crossSystem != null &&
    config.nixpkgs.localSystem.system != null &&
    config.nixpkgs.crossSystem.system != config.nixpkgs.localSystem.system;

  AArch32Overlay = final: super:
    # Ensure pkgsBuildBuild ends up unmodified, otherwise the canary test will
    # get super expensive to build.
    if super.stdenv.buildPlatform == super.stdenv.hostPlatform then {} else {
    cairo = super.cairo.override { glSupport = false; };
    gnutls = super.gnutls.override { guileBindings = false; };
    libass = super.libass.override { encaSupport = false; };
    # Works around libselinux failure with python on armv7l.
    # LONG_BIT definition appears wrong for platform
    libselinux = (super.libselinux
      .override({
        enablePython = false;
      }))
      .overrideAttrs (_: {
        preInstall = ":";
      })
    ;
    polkit = super.polkit.override { withIntrospection = false; };
  };
in
lib.mkIf isCross
{
  # disable more stuff to minimize cross-compilation
  # some from: https://github.com/illegalprime/nixos-on-arm/blob/master/images/mini/default.nix

  boot.enableContainers = false;

  documentation.info.enable = false;

  documentation.man.enable = false;

  environment.noXlibs = true;

  # building '/nix/store/eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee-fc-cache.drv'...
  # [...]-fontconfig-2.10.2-aarch64-unknown-linux-gnu-bin/bin/fc-cache: cannot execute binary file: Exec format error
  fonts.fontconfig.enable = false;

  programs.command-not-found.enable = false;

  security.audit.enable = false;

  # building '/nix/store/eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee-mesa-19.3.3-aarch64-unknown-linux-gnu.drv'...
  # meson.build:1537:2: ERROR: Dependency "wayland-scanner" not found, tried pkgconfig
  security.polkit.enable = false;

  # udisks fails due to gobject-introspection being not cross-compilation friendly.
  services.udisks2.enable = false;

  nixpkgs.overlays = lib.mkMerge [
    (lib.mkIf config.nixpkgs.crossSystem.isAarch32 [ AArch32Overlay ])
  ];
}
