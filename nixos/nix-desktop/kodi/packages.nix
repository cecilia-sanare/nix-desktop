{ lib, config, pkgs, ... }:
let
  cfg = config.nix-desktop;

  libx = import ../../../lib { inherit config pkgs; };
  inherit (lib) mkOption mkIf types;
  inherit (types) nullOr listOf;
in
{
  options.nix-desktop.kodi.packages = mkOption {
    description = "The kodi packages you'd like to install.";
    type = listOf (types.package);
    example = "with pkgs.kodiPackages; [ jellyfin ]";
    default = [ ];
  };

  config = mkIf (cfg.enable && libx.isKodi) {
    services.xserver.desktopManager.kodi.package = pkgs.kodi.passthru.withPackages (_: cfg.kodi.packages);
  };
}
