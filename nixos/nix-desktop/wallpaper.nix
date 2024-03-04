{ lib, config, pkgs, desktop, ... }:


let
  libx = import ../../lib { inherit config; };
  cfg = config.nix-desktop;

  default-wallpaper = {
    dark = "file://${pkgs.nixos-artwork.wallpapers.nineish-dark-gray.src}";
    light = "file://${pkgs.nixos-artwork.wallpapers.nineish.src}";
  }.${libx.theme};

  inherit (lib) types mkIf mkOption;
  inherit (types) nullOr;
in
{
  options.nix-desktop.wallpaper = mkOption {
    description = "The wallpaper you'd like!";
    type = nullOr (types.str);
    default = default-wallpaper;
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
