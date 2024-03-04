{ lib, config, types, pkgs, ... }: let 
  cfg = config.nix-desktop;

  # Nvidia GPUs via the proprietary driver are hit and miss on Wayland unfortunately.
  # Hence why this check exists
  isNvidia = builtins.elem "nvidia" config.services.xserver.videoDrivers;
  isNotNvidia = !isNvidia;
  
  isGnome = cfg.enable && cfg.type == "gnome";

  inherit (lib) mkIf mkDefault;
in {
  config = mkIf(isGnome) {
    services = {
      xserver.desktopManager.gnome.enable = true;
      xserver.displayManager.gdm = {
        enable = true;
        wayland = isNotNvidia;
      };
    };
  };
}