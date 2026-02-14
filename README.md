# zen-browser-nix
Stable package of zen-browser for NixOS.

## Install (flake)
```sh
nix profile install github:XsnilzX/zen-browser-nix
```

Run directly:
```sh
nix run github:XsnilzX/zen-browser-nix
```

## NixOS module
```nix
{
  inputs.zen-browser.url = "github:XsnilzX/zen-browser-nix";

  outputs = { self, nixpkgs, zen-browser, ... }:
  let
    system = "x86_64-linux";
  in {
    nixosConfigurations.host = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        zen-browser.nixosModules.default
        ({ pkgs, ... }: {
          programs.zen-browser.enable = true;
          programs.zen-browser.package =
            zen-browser.packages.${pkgs.system}.zen-browser-stable-bin;
        })
      ];
    };
  };
}
```
