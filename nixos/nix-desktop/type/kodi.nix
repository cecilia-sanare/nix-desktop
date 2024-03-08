{ lib, config, types, pkgs, ... }:
let
  cfg = config.nix-desktop;

  libx = import ../../../lib { inherit config pkgs; };
  inherit (lib) mkIf mkDefault;
in
{
  config = mkIf (cfg.enable && libx.isKodi) {
    services.xserver.desktopManager.kodi.enable = true;
  };
}
