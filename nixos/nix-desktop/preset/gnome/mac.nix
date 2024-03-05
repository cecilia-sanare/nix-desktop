# ##############
# Gnome MacOS #
# ###############################################################
# An opinionated gnome environment focused on emulating MacOS ##
# #############################################################

# TODO:
# - Nautilus currently isn't customized
# - Install the firefox theme

{ inputs, lib, pkgs, config, ... }:

let
  libx = import ../../../../lib { inherit config pkgs; };
  cfg = config.nix-desktop;

  extensions = with pkgs.gnomeExtensions; [
    just-perfection
    dash-to-dock
    appindicator
    blur-my-shell
  ];

  wallpaper = {
    dark = "https://raw.githubusercontent.com/vinceliuice/WhiteSur-wallpapers/main/4k/Monterey.jpg";
    light = "https://raw.githubusercontent.com/vinceliuice/WhiteSur-wallpapers/main/4k/WhiteSur-light.jpg";
  }.${libx.theme};

  isEnabled = cfg.type == "gnome" && cfg.preset == "mac";

  inherit (lib) mkIf mkDefault;
in
{
  config = mkIf (isEnabled) {
    environment.systemPackages = with pkgs; extensions ++ [
      apple-cursor
      whitesur-icon-theme
      whitesur-gtk-theme
      whitesur-kde
    ];

    nix-desktop.theme.gtk = {
      light = mkDefault "WhiteSur";
      dark = mkDefault "WhiteSur-Dark";
    };

    nix-desktop.theme.qt = {
      light = mkDefault "WhiteSur";
      dark = mkDefault "WhiteSur-Dark";
    };

    nix-desktop.theme.icons = {
      light = mkDefault "WhiteSur";
      dark = mkDefault "WhiteSur-Dark";
    };

    nix-desktop.theme.cursors = {
      size = mkDefault 32;
      light = mkDefault "macOS-Monterey-White";
      dark = mkDefault "macOS-Monterey";
    };

    nix-desktop.wallpaper = mkDefault wallpaper;

    programs.dconf.profiles.user.databases =
      let
        inherit (lib.gvariant) mkInt32;
      in
      [{
        settings = {
          "org/gnome/desktop/interface".enable-hot-corners = false;
          "org/gnome/mutter".edge-tiling = true;
          "org/gnome/nautilus/icon-view".default-zoom-level = "small-plus";

          "org/gnome/desktop/wm/preferences".button-layout = ":minimize,maximize,close";

          "org/gnome/shell/extensions/dash-to-dock" = {
            click-action = "minimize-or-previews";
            show-trash = true;
            show-show-apps-button = false;
            dash-max-icon-size = mkInt32 80;
            multi-monitor = true;
            running-indicator-style = "DOTS";
            apply-custom-theme = true;
            custom-theme-shrink = true;
          };

          "org/gnome/shell".enabled-extensions = map (x: x.extensionUuid) extensions;
        };
      }];
  };
}
