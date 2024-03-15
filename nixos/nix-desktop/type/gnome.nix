{ lib, config, types, pkgs, ... }:
let
  cfg = config.nix-desktop;

  libx = import ../../../lib { inherit config pkgs; };
  inherit (lib) mkIf mkDefault mkEnableOption;
  isWayland = cfg.nvidia.allow-wayland || libx.isNotNvidia;
in
{
  options.nix-desktop.nvidia.allow-wayland = mkEnableOption "wayland support on nvidia";

  config = mkIf (cfg.enable && libx.isGnome) {
    services = {
      xserver.desktopManager.gnome.enable = true;
      xserver.displayManager.gdm = {
        enable = true;
        wayland = isWayland;
      };
    };

    # This fixes cursor scaling issues on Wayland for Electron
    environment.sessionVariables.NIXOS_OZONE_WL = mkIf (isWayland) "1";

    programs.dconf.profiles.user.databases = [
      (mkIf (isWayland) {
        # VSCode and other apps get all blurry without this when NIXOS_OZONE_WL is set
        settings."org/gnome/mutter".experimental-features = [ "scale-monitor-framebuffer" ];
      })
    ];
  };
}
