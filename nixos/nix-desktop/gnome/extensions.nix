{ lib, config, pkgs, ... }:
let
  cfg = config.nix-desktop;

  libx = import ../../../lib { inherit config pkgs; };
  inherit (lib) mkOption mkIf types;
  inherit (types) nullOr listOf;
in
{
  options.nix-desktop.gnome.extensions = mkOption {
    description = "The gnome extensions you'd like to install and enable.";
    type = listOf (types.package);
    example = "with pkgs.gnomeExtensions; [ user-themes ]";
    default = [ ];
  };

  config = mkIf (cfg.enable && libx.isGnome) {
    environment.systemPackages = cfg.gnome.extensions;

    programs.dconf.profiles.user.databases = [{
      settings = {
        "org/gnome/shell".enabled-extensions = map (x: x.extensionUuid) cfg.gnome.extensions;
      };
    }];
  };
}
