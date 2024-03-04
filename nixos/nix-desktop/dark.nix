{ lib, config, types, pkgs, ... }: let 
  cfg = config.nix-desktop;

  isGnome = cfg.type == "gnome";

  inherit (lib) mkIf mkEnableOption mkMerge;
in {
  options.nix-desktop.dark = mkEnableOption "dark mode" // {
    default = true;
  };

  config = mkIf(cfg.enable) (mkMerge [
    (mkIf(isGnome) {
      qt.style = if cfg.dark then "adwaita-dark" else "adwaita";

      programs.dconf.profiles.user.databases = [{
        settings = {
          "org/gnome/desktop/interface".gtk-theme = if cfg.dark then "Adwaita-dark" else "Adwaita";
          "org/gnome/desktop/interface".color-scheme = if cfg.dark then "prefer-dark" else "prefer-light";
        };
      }];
    })
  ]);
}