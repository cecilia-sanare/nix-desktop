{ lib, config, pkgs, desktop, ... }:


let
  cfg = config.nix-desktop;

  inherit (lib) types mkIf mkOption;
  inherit (types) nullOr;
in
{
  options.nix-desktop.wallpaper = mkOption {
    description = "The wallpaper you'd like!";
    type = nullOr (types.str);
    default = null;
  };

  config = mkIf (cfg.enable && cfg.wallpaper != null) {
    programs.dconf.profiles.user.databases = [{
      settings = {
        "org/gnome/desktop/background" = {
          picture-uri = cfg.wallpaper;
          picture-uri-dark = cfg.wallpaper;
        };
        "org/gnome/desktop/screensaver" = {
          picture-uri = cfg.wallpaper;
        };
      };
    }];
  };
}
