{ lib, config, types, pkgs, ... }:
let
  super-cfg = config.nix-desktop;
  cfg = super-cfg.theme;

  default-theme = {
    gnome = "adwaita";
  }.${super-cfg.type};

  getTheme = theme: if cfg.dark then "${theme}-dark" else theme;
  theme = getTheme (cfg.name);

  extensions = with pkgs.gnomeExtensions; [
    user-themes
  ];

  libx = import ../../lib { inherit config; };
  inherit (lib) mkIf mkEnableOption mkMerge mkOption mkDefault types;
in
{
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

  config = mkIf (cfg.enable) (mkMerge [
    (mkIf (libx.isGnome) {
      environment.systemPackages = extensions;
      # qt = {
      #   enable = true;
      #   platformTheme = super-cfg.type;
      #   style = mkDefault getTheme(default-theme);
      # };

      programs.dconf.profiles.user.databases = [{
        settings = {
          "org/gnome/desktop/interface".gtk-theme = theme;
          "org/gnome/desktop/interface".color-scheme = if cfg.dark then "prefer-dark" else "prefer-light";
          "org/gnome/shell/extensions/user-theme".name = theme;
          "org/gnome/shell".enabled-extensions = map (x: x.extensionUuid) extensions;
        };
      }];

      environment.variables = {
        QT_STYLE_OVERRIDE = theme;
      };
    })
  ]);
}
