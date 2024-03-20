{ lib, config, pkgs, ... }:
let
  cfg = config.nix-desktop;

  inherit (lib) mkOption mkIf types;
  inherit (types) listOf nullOr;
in
{
  options.nix-desktop.default-installed-apps = mkOption {
    description = "The default desktop environment apps";
    type = nullOr (listOf (types.package));
    default = if cfg.type == null then null else
    (with pkgs; {
      gnome = [
        gnome.gnome-terminal
        gnome.file-roller
        gnome.nautilus
        gnome.gnome-system-monitor
        baobab # Disk usage analyzer
        gparted
        gnome.eog # Image Viewer
        vlc
      ];
    }.${cfg.type} or [ ]);
  };

  config = mkIf (cfg.enable && cfg.default-apps != null) {
    # Seems redundant to have two terminals
    services.xserver.excludePackages = with pkgs; [ xterm ];
    services.gnome.core-utilities.enable = false;

    environment.gnome.excludePackages = with pkgs; [
      gnome-tour
    ];

    environment.systemPackages = cfg.default-apps;
  };
}
