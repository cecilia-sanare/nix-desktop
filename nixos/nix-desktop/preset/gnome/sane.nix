{ lib, config, types, pkgs, ... }:
let
  cfg = config.nix-desktop;

  extensions = with pkgs; [
    gnomeExtensions.user-themes
    gnomeExtensions.hide-activities-button
    gnomeExtensions.just-perfection
    gnomeExtensions.dash-to-dock
    gnomeExtensions.appindicator
  ];

  isEnabled = cfg.type == "gnome" && cfg.preset == "sane";

  inherit (lib) mkIf mkDefault;
in
{
  config = mkIf (isEnabled) {
    environment.systemPackages = with pkgs; extensions;

    nix-desktop.workspaces.number = mkDefault 1;

    programs.dconf.profiles.user.databases =
      let
        inherit (lib.gvariant) mkInt32;
      in
      [{
        settings = {
          "org/gnome/desktop/interface".enable-hot-corners = false;
          "org/gnome/mutter".edge-tiling = true;
          "org/gnome/desktop/wm/preferences".button-layout = "minimize,maximize,close:";
          "org/gnome/nautilus/icon-view".default-zoom-level = "small-plus";

          "org/gnome/shell/extensions/dash-to-dock" = {
            click-action = "minimize-or-previews";
            show-trash = false;
            dash-max-icon-size = mkInt32 80;
            multi-monitor = true;
            running-indicator-style = "DOTS";
            custom-theme-shrink = false;
          };

          "org/gnome/shell".enabled-extensions = map (x: x.extensionUuid) extensions;
        };
      }];
  };
}
