{ lib, config, types, pkgs, ... }: let 
  super-cfg = config.nix-desktop;
  cfg = super-cfg.theme;

  default-theme = {
    gnome = "adwaita";
  }.${super-cfg.type};

  theme = if cfg.dark then "${cfg.name}-dark" else cfg.name;

  isGnome = super-cfg.type == "gnome";

  inherit (lib) mkIf mkEnableOption mkMerge mkOption types;
in {
  options.nix-desktop.theme = {
    enable = mkEnableOption "theme configuration" // {
      default = true;
    };
    
    name = mkOption {
      description = "The theme to use.";
      type = types.str;
      default = default-theme;
    };

    dark = mkEnableOption "dark mode" // {
      default = true;
    };
  };

  config = mkIf(cfg.enable) (mkMerge [
    (mkIf(isGnome) {
      qt.style = theme;

      programs.dconf.profiles.user.databases = [{
        settings = {
          "org/gnome/desktop/interface".gtk-theme = theme;
          "org/gnome/desktop/interface".color-scheme = if cfg.dark then "prefer-dark" else "prefer-light";
        };
      }];
    })
  ]);
}