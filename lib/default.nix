{ config, ... }:
let
  isHeadless = config.nix-desktop.type == null;
  isNotHeadless = !isHeadless;
  isGnome = config.nix-desktop.type == "gnome";

  isVideoDriver = driver: builtins.elem driver config.services.xserver.videoDrivers;

  isNvidia = isVideoDriver "nvidia";
  isNotNvidia = !isNvidia;

  isAMD = isVideoDriver "amd";
  isNotAMD = !isAMD;

  isIntel = isVideoDriver "intel";
  isNotIntel = !isIntel;
in
{
  inherit isHeadless isNotHeadless isGnome;
  inherit isNvidia isNotNvidia isAMD isNotAMD isIntel isNotIntel;
}
