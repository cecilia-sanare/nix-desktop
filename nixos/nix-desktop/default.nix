{ lib, config, pkgs, ... }:
let
  cfg = config.nix-desktop;

  libx = import ../../lib { inherit config pkgs; };
  inherit (lib) mkEnableOption mkOption mkDefault mkIf mkMerge types;
  inherit (types) listOf nullOr;
in
{
  imports = [
    ./type # settings for  'nix-desktop.type'
    ./preset # settings for  'nix-desktop.preset'
    ./kodi # settings for  'nix-desktop.kodi'
    ./gnome # settings for 'nix-desktop.gnome'
    ./alerts.nix # settings for 'nix-desktop.alerts'
    ./audio.nix # settings for 'nix-desktop.audio'
    ./clock.nix # settings for 'nix-desktop.clock'
    ./default-apps.nix # settings for 'nix-desktop.default-apps'
    ./default-installed-apps.nix # settings for 'nix-desktop.default-installed-apps'
    ./sleep.nix # settings for 'nix-desktop.sleep'
    ./theme.nix # settings for 'nix-desktop.theme'
    ./wallpaper.nix # settings for 'nix-desktop.wallpaper'
    ./workspaces.nix # settings for 'nix-desktop.workspaces'
  ];

  options.nix-desktop.enable = mkEnableOption "nix-desktop configuration";

  config = mkIf (cfg.enable && libx.isNotHeadless) {
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = mkDefault libx.has32BitSupport;
      extraPackages = with pkgs; [
        (mkIf libx.isAMD amdvlk)
        (mkIf libx.isIntel intel-media-driver)
        (mkIf libx.isIntel vaapiIntel)
        (mkIf libx.isIntel vaapiVdpau)
        (mkIf libx.isIntel libvdpau-va-gl)
        libva
      ];
    };

    services.xserver.enable = true;
  };
}
