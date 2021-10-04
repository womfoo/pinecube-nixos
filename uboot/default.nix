{ pkgs, fetchurl }:

pkgs.buildUBoot rec {

  version = "2020.10";

  src = fetchurl {
    url = "ftp://ftp.denx.de/pub/u-boot/u-boot-${version}.tar.bz2";
    sha256 = "08m6f1bh4pdcqbxf983qdb66ccd5vak5cbzc114yf3jwq2yinj0d";
  };

  patches = [ ./Pine64-PineCube-uboot-support.patch ];

  defconfig = "pinecube_defconfig";

  # Putting this here because it's more a design choice and not generic support
  # for hardware.
  extraConfig = ''
    CONFIG_CMD_BOOTMENU=y
  '';

  extraMeta.platforms = ["armv7l-linux"];
  filesToInstall = ["u-boot-sunxi-with-spl.bin"];

}
