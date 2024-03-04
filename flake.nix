{
  description = "Configurable Desktops for Nix";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }: {
    nixosModules = let 
      nix-desktop = import ./nixos;
    in {
      nix-desktop = nix-desktop;
      default = nix-desktop;
    };
    # deprecated in Nix 2.8
    nixosModule = self.nixosModules.default;
  };
}
