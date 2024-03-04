{ lib, config, types, pkgs, ... }:
let
  cfg = config.nix-desktop;

  libx = import ../../lib { inherit config pkgs; };
  inherit (lib) mkIf mkOption types;
in
{
  options.nix-desktop.clock = mkOption {
    description = "The clock format to use";
    type = types.enum ([ "12h" "24h" ]);
    default = "12h";
  };

  config = mkIf (cfg.enable) {
    programs.dconf = {
      enable = true;

      profiles = {
        user.databases = [
          (mkIf (libx.isGnome) {
            settings = {
              "org/gnome/desktop/interface".clock-format = cfg.clock;
            };
          })
        ];
      };
    };
  };
}
