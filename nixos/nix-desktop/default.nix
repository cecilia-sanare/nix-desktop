{ lib, config, pkgs, ... }:
let
  cfg = config.nix-desktop;

  themes = {
    gnome = [ "sane" ];
  };

  # Nvidia GPUs via the proprietary driver are hit and miss on Wayland unfortunately.
  # Hence why this check exists
  isNvidia = builtins.elem "nvidia" config.services.xserver.videoDrivers;
  isNotNvidia = !isNvidia;
  # Used purely for opengl drivers
  isAMD = builtins.elem "amd" config.services.xserver.videoDrivers;
  isIntel = builtins.elem "intel" config.services.xserver.videoDrivers;

  isHeadless = cfg.type == null;
  isNotHeadless = !isHeadless;

  inherit (lib) mkEnableOption mkOption mkIf mkMerge types;
  inherit (types) listOf nullOr;
in
{
  imports = [
    ./type
    ./preset
    ./dark.nix
    ./alerts.nix
    ./clock.nix
    ./sleep.nix
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

    defaultApps = mkEnableOption "default desktop environment apps" // {
      default = true;
    };
  };

  config = mkIf (cfg.enable) {
    # TODO: Move sound config into its own module and make it configurable
    environment.systemPackages = with pkgs; [
      pipewire
    ];

    sound.enable = false;
    hardware.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    # Seems redundant to have two terminals
    services.xserver.excludePackages = with pkgs; [ xterm ];

    hardware.opengl = mkIf (isNotHeadless) {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        (mkIf isAMD amdvlk)
        (mkIf isIntel intel-media-driver)
        (mkIf isIntel vaapiIntel)
        (mkIf isIntel vaapiVdpau)
        (mkIf isIntel libvdpau-va-gl)
        libva
      ];
    };

    services.xserver.enable = isNotHeadless;
  };
}
