**:warning: WIP :warning:**

#  Ceci's Opinionated NixOS Desktop Environments ❄️ 

> The primary goal of this module is to make swapping between desktop environments as seamless as possible.
> 
>*(also to get my desktop configuration out of my `nix-config`)*

## Supported Desktop Environments

### Gnome

**Stock** 

Just the stock gnome desktop environment with a few minor tweaks based on our defaults

- Audio alerts are off (this can be turned off by setting `nix-desktop.alerts` to `true`)
- Dark mode (this can be turned off by setting `nix-desktop.theme.dark` to `false`)
- Removes all of the stock gnome apps and `xterm`.
- Adds the following default apps (this can be turned off by setting `nix-desktop.default-apps` to `null`):
  - Gnome Terminal
  - Unzip Utility (aka File Roller)
  - File Viewer (aka nautilus)
  - System Monitor
  - Disk Usage Analyzer (aka boabab)
  - Image Viewer (aka eog)

**Sane**

<details>
  <summary>Screenshots</summary>

  ![Screenshot](./screenshots/sane.png?raw=true)

</details>

- `enable-hot-corners` is set to `false`
- `edge-tiling` is enabled
- Nautilus `default-zoom-level` is set to `small-plus`
- Dash to dock is installed in preconfigured
- Activities button is removed
- Tray icons are enabled

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