{ config, pkgs, ... }:
let
  isHeadless = config.nix-desktop.type == null;
  isNotHeadless = !isHeadless;
  isGnome = config.nix-desktop.type == "gnome";
  isKodi = config.nix-desktop.type == "kodi";

  isVideoDriver = driver: builtins.elem driver config.services.xserver.videoDrivers;

  isNvidia = isVideoDriver "nvidia";
  isNotNvidia = !isNvidia;

  isAMD = isVideoDriver "amd";
  isNotAMD = !isAMD;

  isIntel = isVideoDriver "intel";
  isNotIntel = !isIntel;

  theme = if config.nix-desktop.theme.dark then "dark" else "light";

  has32BitSupport = pkgs.stdenv.isx86_64 || config.boot.kernelPackages.kernel.features.ia32Emulation or false;
in
{
  inherit isHeadless isNotHeadless isGnome;
  inherit isNvidia isNotNvidia isAMD isNotAMD isIntel isNotIntel;
  inherit theme;
}
