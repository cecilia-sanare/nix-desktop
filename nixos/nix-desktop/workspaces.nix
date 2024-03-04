{ lib, config, types, pkgs, ... }:
let
  super_cfg = config.nix-desktop;
  cfg = super_cfg.workspaces // {
    enable = super_cfg.enable && super_cfg.workspaces != null;
  };

  libx = import ../../lib { inherit config; };
  inherit (lib) mkEnableOption mkOption mkIf mkMerge types;
  inherit (types) listOf nullOr submodule;
in
{
  options.nix-desktop.workspaces = mkOption {
    description = "The workspace configuration";
    type = nullOr (submodule {
      options = {
        number = mkOption {
          description = "The number of workspaces";
          type = nullOr (types.int);
          default = 4;
        };

        dynamic = mkEnableOption "dynamic workspaces";
      };
    });
    default = null;
  };

  config = mkIf (cfg.enable) {
    programs.dconf.profiles.user.databases =
      let
        inherit (lib.gvariant) mkInt32;
      in
      [
        (mkIf (libx.isGnome) {
          settings = {
            "org/gnome/mutter".dynamic-workspaces = cfg.dynamic;
            "org/gnome/desktop/wm/preferences".num-workspaces = mkInt32 cfg.number;
          };
        })
      ];
  };
}
