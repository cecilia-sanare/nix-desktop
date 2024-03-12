{ lib, config, types, pkgs, ... }:
let
  cfg = config.nix-desktop;

  libx = import ../../../lib { inherit config pkgs; };
  inherit (lib) mkIf mkDefault mkEnableOption;
in
{
  options.nix-desktop.nvidia.allow-wayland = mkEnableOption "wayland support on nvidia";

  config = mkIf (cfg.enable && libx.isGnome) {
    services = {
      xserver.desktopManager.gnome.enable = true;
      xserver.displayManager.gdm = {
        enable = true;
        wayland = cfg.nvidia.allow-wayland || libx.isNotNvidia;
      };
    };
  };
}
