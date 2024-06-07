{
  description = "poly-runtest flake";

  inputs = { };

  outputs = { self, ... }:
    let
      # put devShell and any other required packages into local overlay
      localOverlay = import ./nix/overlay.nix;

      pkgsForSystem = system: import nixpkgs {
        overlays = [ localOverlay ];
        inherit system;
      };
    # https://github.com/numtide/flake-utils#usage for more examples
    in {
    overlays.default = localOverlay;
    nixosModules.default = { nixpkgs.overlays = [ localOverlay ]; };
  };
}
