{
  description = "Example poly nixpkgs tests";

  inputs = {
    nixpkgs-2311.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-2405.url = "github:nixos/nixpkgs/nixos-24.05";
    poly-test.url = "github:jonringer/nixos-polytest";
  };

  outputs = { nixpkgs-2311, nixpkgs-2405, poly-test, self }: let
    hostPkgs = import nixpkgs-2311 { system = "x86_64-linux"; };
    runPolyTest = poly-test.lib.mkRunPolyTest hostPkgs;
  in {
    checks.x86_64-linux.example = runPolyTest {
      name = "example-polytest";
      testScript = ''
        start_all()
        foo.wait_for_unit("multi-user.target")
        bar.wait_for_unit("multi-user.target")

        foo.succeed("grep 23.11 /etc/os-release")
        bar.succeed("grep 24.05 /etc/os-release")
      '';
      nodes.a = {
        nixpkgsPath = toString nixpkgs-2311;
        specialArgs = { };
        modules = [ {
          system.name = "foo";
        }];
      };
      nodes.b = {
        nixpkgsPath = toString nixpkgs-2405;
        specialArgs = { };
        modules = [ {
          system.name = "bar";
        }];
      };
    };
  };
}
