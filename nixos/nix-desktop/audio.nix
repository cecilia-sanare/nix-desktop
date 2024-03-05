{ lib, config, pkgs, ... }:
let
  cfg = config.nix-desktop;

  inherit (lib) mkOption mkIf mkDefault types;
  inherit (types) nullOr;
in
{
  options.nix-desktop.audio = mkOption {
    description = "The audio server to use";
    type = nullOr (types.enum ([ "pulseaudio" "pipewire" ]));
    default = "pipewire";
  };

  config =
    let
      isPipewire = cfg.audio == "pipewire";
      isPulseaudio = cfg.audio == "pulseaudio";
    in
    mkIf (cfg.enable) {
      environment.systemPackages = with pkgs; [
        (mkIf (isPipewire) pipewire)
      ];

      sound.enable = isPulseaudio;
      hardware.pulseaudio.enable = isPulseaudio;
      security.rtkit.enable = mkDefault true;
      services.pipewire = mkIf (isPipewire) {
        enable = true;
        alsa.enable = mkDefault true;
        alsa.support32Bit = mkDefault true;
        pulse.enable = mkDefault true;
        jack.enable = mkDefault true;
        wireplumber.enable = mkDefault true;
      };
    };
}
