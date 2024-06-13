{
  description = "poly-runtest flake";

  inputs = {
    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
  };

  outputs = { nixpkgs-lib, ... }: {
    lib = import ./lib { inherit (nixpkgs-lib) lib; };
  };
}
