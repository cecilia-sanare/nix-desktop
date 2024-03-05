{ lib, config, types, pkgs, ... }:
let
  inherit (lib) mkIf mkEnableOption mkMerge mkOption mkDefault types;
  inherit (types) nullOr;
  libx = import ../../lib { inherit config pkgs; };

  super-cfg = config.nix-desktop;
  cfg = super-cfg.theme;

  default-theme = {
    gnome = {
      themes = {
        gtk = {
          light = "Adwaita";
          dark = "Adwaita-dark";
        };
        qt = {
          light = "adwaita";
          dark = "adwaita-dark";
        };
      };
      icons = {
        light = "Adwaita";
        dark = "Adwaita";
      };
      cursors = {
        light = "Adwaita";
        dark = "Adwaita";
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

  cursorSubmodule = types.submodule {
    options = {
      size = mkOption {
        description = "The size of the cursor.";
        type = types.int;
        default = 32;
        example = 64;
      };

      light = mkOption {
        description = "The light cursor theme to use.";
        type = types.str;
      };

      dark = mkOption {
        description = "The dark cursor theme to use.";
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
      default = default-theme.themes.gtk;
    };

    qt = mkOption {
      description = "The qt theme to use.";
      type = themeSubmodule;
      default = default-theme.themes.qt;
    };

    icons = mkOption {
      description = "The icon theme to use.";
      type = themeSubmodule;
      default = default-theme.icons;
    };

    cursors = mkOption {
      description = "The cursor theme to use.";
      type = cursorSubmodule;
      default = default-theme.cursors;
    };

    dark = mkEnableOption "dark mode" // {
      default = true;
    };
  };

  config = mkIf (cfg.enable) (mkMerge [
    {
      environment.variables = mkIf (cfg.cursors != null) {
        XCURSOR_SIZE = mkDefault (builtins.toString (cfg.cursors.size));
        XCURSOR_THEME = mkDefault cfg.cursors.${libx.theme};
      };
    }
    (mkIf (libx.isGnome) {
      environment.systemPackages = with pkgs; extensions ++ [
        gnome.gnome-themes-extra
        adwaita-qt
        adwaita-qt6
      ];

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
            settings."org/gnome/desktop/interface".cursor-size = mkInt32 32;
            settings."org/gnome/desktop/interface".cursor-theme = cfg.cursors.${libx.theme};
          })
        ];

      environment.variables = {
        QT_STYLE_OVERRIDE = qt-theme;
      };
    })
  ]);
}
