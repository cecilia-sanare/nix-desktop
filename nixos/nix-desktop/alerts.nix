{ lib, config, pkgs, ... }: let 
  cfg = config.nix-desktop;
  isGnome = cfg.type == "gnome";

  inherit (lib) mkEnableOption mkIf;
in {
  options.nix-desktop.alerts = mkEnableOption "audio alerts";

  config = mkIf (cfg.enable) {
    services.pipewire = mkIf(cfg.audio == "pipewire") {
      extraConfig.pipewire."99-silent-bell".context.properties."module.x11.bell" = cfg.alerts;
    };

    programs.dconf.profiles.user.databases = [
      (mkIf(isGnome) {
        settings = {
          "org/gnome/desktop/sound".event-sounds = cfg.alerts;
        };
      })
    ];
  };
}