{ config, pkgs, ... }:
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

  theme = if config.nix-desktop.theme.dark then "dark" else "light";

  fetchCursor = { name, url, hash ? "" }: {
    inherit name;
    package = pkgs.runCommand "moveUp" { } ''
      mkdir -p $out/share/icons
      ln -s ${pkgs.fetchzip {
        inherit url hash;
      }} $out/share/icons/${name}
    '';
  };
in
{
  inherit isHeadless isNotHeadless isGnome;
  inherit isNvidia isNotNvidia isAMD isNotAMD isIntel isNotIntel;
  inherit theme fetchCursor;
}
