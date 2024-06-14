{
  description = "Example poly nixpkgs tests";

  inputs = {
    nixpkgs-2311.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-2405.url = "github:nixos/nixpkgs/nixos-24.05";
    poly-test.url = "github:jonringer/nixos-polytest?ref=master";
  };

  outputs = { nixpkgs-2311, nixpkgs-2405, poly-test, self }: {
    checks = poly-test.lib.runPolyTest {
      nodes.a = {
        nixpkgsPath = toString nixpkgs-2311;
        specialArgs = { };
        modules = [ ];
      };
      nodes.b = {
        nixpkgsPath = toString nixpkgs-2405;
        specialArgs = { };
        modules = [ ];
      };
    };
  };
}
