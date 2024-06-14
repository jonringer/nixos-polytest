{ lib }:
let

  evalTest = pkgs: module: lib.evalModules {
    specialArgs = { hostPkgs = pkgs; };
    modules = testModules ++ [ module ];
    class = "nixosTest";
  };

  mkRunPolyTest = pkgs: module: (evalTest pkgs ({ config, ... }: {
    imports = [ module ];
    result = config.test;
  })).config.result;

  testModules = [
    ./call-test.nix
    ./driver.nix
    ./interactive.nix
    ./legacy.nix
    ./meta.nix
    ./name.nix
    ./network.nix
    ./nodes.nix
    ./pkgs.nix
    ./run.nix
    ./testScript.nix
  ];

in
{
  inherit evalTest mkRunPolyTest testModules;
}
