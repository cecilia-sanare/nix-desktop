{ lib, config, ... }:
let
  cfg = config.nix-desktop;

  presets = {
    gnome = [ "sane" "mac" ];
  };

  inherit (lib) mkOption types;
  inherit (types) nullOr;
in
{
  imports = [
    ./gnome
  ];

  options.nix-desktop.preset = mkOption {
    description = "The desktop preset to use (null just uses the stock gnome config)";
    type = nullOr (types.enum (if cfg.type == null then [ ] else presets.${cfg.type}));
    default = null;
  };
}
