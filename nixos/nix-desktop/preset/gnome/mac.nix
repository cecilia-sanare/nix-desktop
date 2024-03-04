# ##############
# Gnome MacOS #
# ###############################################################
# An opinionated gnome environment focused on emulating MacOS ##
# #############################################################

# TODO:
# - Nautilus currently isn't customized
# - Install the firefox theme
# - Figure out how to specify the cursor w/o home-manager

{ inputs, lib, pkgs, config, ... }:

let
  cfg = config.nix-desktop;

  extensions = with pkgs.gnomeExtensions; [
    hide-activities-button
    just-perfection
    dash-to-dock
    appindicator
  ];

  wallpaper = {
    dark = "https://raw.githubusercontent.com/vinceliuice/WhiteSur-wallpapers/main/4k/Monterey.jpg";
    light = "https://raw.githubusercontent.com/vinceliuice/WhiteSur-wallpapers/main/4k/WhiteSur-light.jpg";
  }.${if cfg.theme.dark then "dark" else "light"};

  isEnabled = cfg.type == "gnome" && cfg.preset == "mac";

  inherit (lib) mkIf mkDefault;
in
{
  config = mkIf (isEnabled) {
    nix-desktop.theme.name = mkDefault "WhiteSur";
    nix-desktop.wallpaper = mkDefault wallpaper;

    environment.systemPackages = with pkgs; extensions ++ [
      whitesur-icon-theme
      whitesur-gtk-theme
      whitesur-kde
    ];

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

    # TODO: Find a way to change the background and cursor w/o home-manager
    # home-manager.sharedModules = [
    #   ({ config, ... }: {
    #     dotfiles.desktop = {
    #       enable = mkDefault true;
    #       background = mkDefault "https://raw.githubusercontent.com/vinceliuice/WhiteSur-wallpapers/main/2k/Monterey.jpg";

    #       cursor = mkDefault {
    #         enable = true;
    #         url = "https://github.com/ful1e5/apple_cursor/releases/download/v2.0.0/macOS-BigSur.tar.gz";
    #         hash = "sha256-VZWFf1AHum2xDJPMZrBmcyVrrmYGKwCdXOPATw7myOA=";
    #         name = "macOS-BigSur";
    #       };
    #     };

    #   })
    # ];
  };
}
