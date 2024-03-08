{ lib, ... }:
let
  inherit (lib) mkOption types;
  inherit (types) nullOr;
in
{
  imports = [
    ./gnome.nix
    ./kodi.nix
    # ./plasma.nix
  ];

  options.nix-desktop.type = mkOption {
    description = "The desktop environment to use";
    type = nullOr (types.enum ([ "gnome" "kodi" ]));
    default = null;
  };
}
