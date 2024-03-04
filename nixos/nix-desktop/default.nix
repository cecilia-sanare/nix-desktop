{ lib, config, pkgs, ... }:
let
  cfg = config.nix-desktop;

  themes = {
    gnome = [ "sane" "mac" ];
  };

  libx = import ../../lib { inherit config pkgs; };
  inherit (lib) mkEnableOption mkOption mkIf mkMerge types;
  inherit (types) listOf nullOr;
in
{
  imports = [
    ./preset
    ./type
    ./alerts.nix
    ./audio.nix
    ./clock.nix
    ./default-apps.nix
    ./sleep.nix
    ./theme.nix
    ./wallpaper.nix
    ./workspaces.nix
  ];

  options.nix-desktop = {
    enable = mkEnableOption "nix-desktop configuration";

    type = mkOption {
      description = "The desktop environment to use";
      type = nullOr (types.enum ([ "gnome" ]));
      default = null;
    };

    preset = mkOption {
      description = "The desktop preset to use (null just uses the stock gnome config)";
      type = nullOr (types.enum (if cfg.type == null then [ ] else themes.${cfg.type}));
      default = null;
    };
  };

  config = mkIf (cfg.enable && libx.isNotHeadless) {
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
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
