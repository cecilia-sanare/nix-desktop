{ lib, config, types, pkgs, ... }:
let
  inherit (lib) mkIf mkEnableOption mkMerge mkOption mkDefault types;
  inherit (types) nullOr;
  libx = import ../../lib { inherit config pkgs; };

  super-cfg = config.nix-desktop;
  cfg = super-cfg.theme;

  default-theme = {
    gnome = {
      gtk = {
        light = "adwaita";
        dark = "adwaita-dark";
      };
      qt = {
        light = "adwaita";
        dark = "adwaita-dark";
      };
    };
  }.${super-cfg.type};

  gtk-theme = cfg.gtk.${libx.theme};
  qt-theme = cfg.qt.${libx.theme};

  extensions = with pkgs.gnomeExtensions; [
    user-themes
  ];

  themeSubmodule = types.submodule {
    options = {
      light = mkOption {
        description = "The light theme to use.";
        type = types.str;
      };

      dark = mkOption {
        description = "The dark theme to use.";
        type = types.str;
      };
    };
  };
in
{
  options.nix-desktop.theme = {
    enable = mkEnableOption "theme configuration" // {
      default = true;
    };

    gtk = mkOption {
      description = "The gtk theme to use.";
      type = themeSubmodule;
      default = default-theme.gtk;
    };

    qt = mkOption {
      description = "The qt theme to use.";
      type = themeSubmodule;
      default = default-theme.qt;
    };

    icons = mkOption {
      description = "The icon theme to use.";
      type = nullOr (themeSubmodule);
      default = null;
    };

    cursors = mkOption {
      description = "The cursor theme to use.";
      type = nullOr (themeSubmodule);
      default = null;
    };

    dark = mkEnableOption "dark mode" // {
      default = true;
    };
  };

  config = mkIf (cfg.enable) (mkMerge [
    (mkIf (libx.isGnome) {
      environment.systemPackages = extensions;
      programs.dconf.profiles.user.databases =
        let
          inherit (lib.gvariant) mkInt32;
        in
        [
          {
            settings = {
              "org/gnome/desktop/interface" = {
                gtk-theme = gtk-theme;
                color-scheme = if cfg.dark then "prefer-dark" else "prefer-light";
                cursor-size = mkInt32 32;
              };
              "org/gnome/shell/extensions/user-theme".name = gtk-theme;
              "org/gnome/shell".enabled-extensions = map (x: x.extensionUuid) extensions;
            };
          }
          # TODO: Is there an easier way to do this?
          (mkIf (cfg.icons != null) {
            settings."org/gnome/desktop/interface".icon-theme = cfg.icons.${libx.theme};
          })
          (mkIf (cfg.cursors != null) {
            settings."org/gnome/desktop/interface".cursor-theme = cfg.cursors.${libx.theme};
          })
        ];

      environment.variables = {
        QT_STYLE_OVERRIDE = qt-theme;
      };
    })
  ]);
}
