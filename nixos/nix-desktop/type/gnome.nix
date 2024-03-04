{ lib, config, types, pkgs, ... }:
let
  cfg = config.nix-desktop;

  libx = import ../../lib { inherit config; };
  inherit (lib) mkIf mkDefault;
in
{
  config = mkIf (cfg.enable && libx.isGnome) {
    services = {
      xserver.desktopManager.gnome.enable = true;
      xserver.displayManager.gdm = {
        enable = true;
        wayland = libx.isNotNvidia;
      };
    };
  };
}
