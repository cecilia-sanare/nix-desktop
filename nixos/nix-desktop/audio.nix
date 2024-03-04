{ lib, config, pkgs, ... }: let 
  cfg = {
    enable = config.nix-desktop.enable && config.nix-desktop.audio != null;
    isPipewire = config.nix-desktop.audio == "pipewire";
    isPulseaudio = config.nix-desktop.audio == "pulseaudio";
  };

  inherit (lib) mkOption mkIf types;
  inherit (types) nullOr;
in {
  options.nix-desktop.audio = mkOption {
    description = "The audio server to use";
    type = nullOr(types.enum(["pulseaudio" "pipewire"]));
    default = "pipewire";
  };

  config = mkIf (cfg.enable) {
    # TODO: Move sound config into its own module and make it configurable
    environment.systemPackages = with pkgs; [
      (mkIf (cfg.isPipewire) pulseaudio)
    ];

    services.pipewire = mkIf (cfg.isPipewire == "pipewire") {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    sound.enable = cfg.isPulseaudio;
    hardware.pulseaudio = {
      enable = cfg.isPulseaudio;
      support32Bit = true;
      package = pkgs.pulseaudioFull;
    };
  };
}