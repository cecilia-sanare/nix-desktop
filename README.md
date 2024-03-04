**:warning: WIP :warning:**

#  Ceci's Opinionated NixOS Desktop Environments ❄️ 

## Usage

### `flake.nix` **(RECOMMENDED)**

Even if flakes are still experimental, they're the best way of managing dependencies.

```nix
{
  description = "NixOS Example";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-desktop.url = "github:cecilia-sanare/nix-desktop/main";
    nix-desktop.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, ... } @ inputs: {
    nixosConfigurations =
      let
        inherit (self) outputs;
        inherit (nixpkgs.lib) nixosSystem;
      in
      {
        your-hostname = nixosSystem {
          specialArgs = { inherit inputs outputs; };

          modules = [
            inputs.nix-desktop.nixosModules.default
            # Ideally don't actually put this inline, but you definitely could!
            ({ ... }: {
                nix-desktop = {
                    enable = true;
                    type = "gnome";
                    preset = "sane";
                };
            })
          ];
        };
      };
  };
}
```

### `configuration.nix` **(NOT RECOMMENDED)**

This method of importing modules *really* isn't recommended.
The primary issue is that it doesn't lock down the dependencies which can prevent your nix configuration from being reproducible.

```nix
{ ... }: {
    imports = [
        (import "${builtins.fetchTarball https://github.com/cecilia-sanare/nix-desktop/archive/main.tar.gz}/nixos")
        nix-desktop.nixosModules.default
    ];

    nix-desktop = {
        enable = true;
        type = "gnome";
        preset = "sane";
    };
}
```