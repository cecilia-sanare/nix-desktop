{ lib, config, types, pkgs, ... }:
let
  cfg = config.nix-desktop;

  isEnabled = cfg.type == "gnome" && cfg.preset == "sane";

  inherit (lib) mkIf mkDefault;
in
{
  config = mkIf (isEnabled) {
    nix-desktop.workspaces.number = mkDefault 1;
    nix-desktop.gnome.extensions = with pkgs.gnomeExtensions; [
      user-themes
      hide-activities-button
      just-perfection
      dash-to-dock
      appindicator
    ];

    programs.dconf.profiles.user.databases =
      let
        inherit (lib.gvariant) mkInt32 mkEmptyArray type;
      in
      [{
        settings = {
          "org/gnome/desktop/interface".enable-hot-corners = false;
          "org/gnome/mutter".edge-tiling = true;
          "org/gnome/desktop/wm/preferences".button-layout = ":minimize,maximize,close";
          "org/gnome/nautilus/icon-view".default-zoom-level = "small-plus";

          "org/gnome/shell/extensions/dash-to-dock" = {
            click-action = "minimize-or-previews";
            show-trash = false;
            dash-max-icon-size = mkInt32 80;
            multi-monitor = true;
            running-indicator-style = "DOTS";
            custom-theme-shrink = false;
          };

          "org/gnome/desktop/wm/keybindings" = {
            switch-applications = mkEmptyArray (type.string);
            switch-applications-backward = mkEmptyArray (type.string);
            switch-windows = [ "<Alt>Tab" ];
            switch-windows-backward = [ "<Shift><Alt>Tab" ];
          };
        };
      }];
  };
}
