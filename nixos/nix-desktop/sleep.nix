{ lib, config, pkgs, ... }:
let
  cfg = config.nix-desktop;

  libx = import ../../lib { inherit config pkgs; };
  inherit (lib) mkEnableOption mkIf;
in
{
  options.nix-desktop.sleep = mkEnableOption "sleep" // {
    default = true;
  };

  config = mkIf (cfg.enable) {
    # TODO: Figure out what of these settings are gnome / x11 specific

    # No Sleep Settings

    # Disabling this results in gnome disabling the battery indicator
    # powerManagement.enable = cfg.sleep;

    # Disable the GNOME3/GDM auto-suspend feature that cannot be disabled in GUI!
    # If no user is logged in, the machine will power down after 20 minutes.
    systemd.targets.sleep.enable = cfg.sleep;
    systemd.targets.suspend.enable = cfg.sleep;
    systemd.targets.hibernate.enable = cfg.sleep;
    systemd.targets.hybrid-sleep.enable = cfg.sleep;

    programs.dconf.profiles.user.databases =
      let
        inherit (lib.gvariant) mkInt32 mkUint32;
      in
      [
        (mkIf (libx.isGnome && !cfg.sleep) {
          settings = {
            "org/gnome/settings-daemon/plugins/power" = {
              power-button-action = "nothing";
              sleep-inactive-ac-type = "nothing";
              sleep-inactive-ac-timeout = mkInt32 0;
              sleep-inactive-battery-timeout = mkInt32 0;
            };

            "org/gnome/desktop/session" = {
              idle-delay = mkUint32 0;
            };
          };
        })
      ];
  };
}
