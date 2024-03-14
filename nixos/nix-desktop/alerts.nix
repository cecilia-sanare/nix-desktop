{ lib, config, pkgs, ... }:
let
  cfg = config.nix-desktop;

  libx = import ../../lib { inherit config pkgs; };
  inherit (lib) mkEnableOption mkIf;
in
{
  options.nix-desktop.alerts = mkEnableOption "audio alerts";

  config = mkIf (cfg.enable) {
    # Certain apps (namely firefox) require this to be disabled to turn off alerts
    services.pipewire.extraConfig.pipewire."99-silent-bell" = mkIf (cfg.audio == "pipewire") {
      "context.properties"."module.x11.bell" = cfg.alerts;
    };

    programs.dconf.profiles.user.databases = [
      (mkIf (libx.isGnome) {
        settings = {
          "org/gnome/desktop/sound".event-sounds = cfg.alerts;
        };
      })
    ];
  };
}
