pkgs:
let

  evalTest = module: pkgs.lib.evalModules {
    specialArgs = { hostPkgs = pkgs; };
    modules = testModules ++ [ module ];
    class = "nixosTest";
  };

  runPolyTest = module: (evalTest ({ config, ... }: {
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
  runPolyTest
