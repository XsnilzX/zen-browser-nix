{
  description = "Zen Browser (Stable) via nvfetcher";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
  let
    forAll = f: nixpkgs.lib.genAttrs [ "x86_64-linux" ] (sys: f (import nixpkgs { system = sys; }));
  in {
    packages = forAll (pkgs:
      let
        sources = import ./_sources/generated.nix { };  # <- nvfetcher output
      in {
        zen-browser-stable-bin = pkgs.callPackage ./pkgs/zen {
          inherit sources;
        };

        default = self.packages.${pkgs.stdenv.hostPlatform.system}.zen-browser-stable-bin;
      });

    overlays.default = final: prev: {
      zen-browser-stable-bin =
        self.packages.${prev.stdenv.hostPlatform.system}.zen-browser-stable-bin;
    };
  };
}
