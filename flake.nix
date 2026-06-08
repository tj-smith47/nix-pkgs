{
  description = "Nix flake for release artifacts published by anodize";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      pkgsFor = system: import nixpkgs {
        inherit system;
        overlays = [ self.overlays.default ];
      };
    in
    {
      overlays.default = final: prev: {
        anodizer = final.callPackage ./pkgs/anodizer/default.nix { };
      };

      packages = forAllSystems (system:
        let pkgs = pkgsFor system;
        in {
          anodizer = pkgs.anodizer;
        });
    };
}
