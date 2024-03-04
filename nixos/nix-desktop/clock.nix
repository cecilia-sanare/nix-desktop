{ lib, config, types, pkgs, ... }: let 
  cfg = config.nix-desktop;

  # Nvidia GPUs via the proprietary driver are hit and miss on Wayland unfortunately.
  # Hence why this check exists
  isNvidia = builtins.elem "nvidia" config.services.xserver.videoDrivers;
  isNotNvidia = !isNvidia;
  
  isGnome = cfg.type == "gnome";

  inherit (lib) mkIf mkOption types;
in {
  options.nix-desktop.clock = mkOption {
    description = "The clock format to use";
    type = types.enum ([ "12hr" "24hr" ]);
    default = "12hr";
  };

  config = mkIf(cfg.enable) {
    programs.dconf = {
      enable = true;

      profiles = {
        user.databases = [
          (mkIf(isGnome) {
            settings = {
              "org/gnome/desktop/interface".clock-format = cfg.clock;
            };
          })
        ];
      };
    };
  };
}