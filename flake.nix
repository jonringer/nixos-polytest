{
  description = "poly-runtest flake";

  inputs = { };

  outputs = { ... }: {
    lib = {
      mkRunPolyTest = import ./lib;
    };
  };
}
