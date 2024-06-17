testModuleArgs@{ config, lib, hostPkgs, nodes, ... }:

let
  inherit (lib)
    literalExpression
    literalMD
    mapAttrs
    mkDefault
    mkIf
    mkOption mkForce
    optional
    optionalAttrs
    types
    ;

  inherit (hostPkgs) hostPlatform;

  guestSystem =
    if hostPlatform.isLinux
    then hostPlatform.system
    else
      let
        hostToGuest = {
          "x86_64-darwin" = "x86_64-linux";
          "aarch64-darwin" = "aarch64-linux";
        };

        supportedHosts = lib.concatStringsSep ", " (lib.attrNames hostToGuest);

        message =
          "NixOS Test: don't know which VM guest system to pair with VM host system: ${hostPlatform.system}. Perhaps you intended to run the tests on a Linux host, or one of the following systems that may run NixOS tests: ${supportedHosts}";
      in
        hostToGuest.${hostPlatform.system} or (throw message);

  mkNode = { nixpkgsPath, modules, specialArgs, ... }:
    let
      modulesPath = "${nixpkgsPath}/nixos/modules";
    in
    import "${nixpkgsPath}/nixos/lib/eval-config.nix" {
      lib = import "${nixpkgsPath}/lib";
      system = null; # use modularly defined system
      inherit modules;
      # Re-create nixos-lib/eval-config.nix logic
      specialArgs = {
        inherit modulesPath;
      } // specialArgs;
      baseModules = (import "${nixpkgsPath}/nixos/modules/module-list.nix") ++
        [
          ./nixos-test-base.nix
          ({ config, ... }:
            {
              virtualisation.qemu.package = testModuleArgs.config.qemu.package;
              virtualisation.host.pkgs = hostPkgs;
            })
          ({ options, ... }: {
            key = "nodes.nix-pkgs";
            config = optionalAttrs (!config.node.pkgsReadOnly) (
              mkIf (!options.nixpkgs.pkgs.isDefined) {
                # TODO: switch to nixpkgs.hostPlatform and make sure containers-imperative test still evaluates.
                nixpkgs.system = guestSystem;
              }
            );
          })
        ];
    };

in
{
  options = {
    defaults = mkOption {
      description = ''
        NixOS configuration that is applied to all [{option}`nodes`](#test-opt-nodes).
      '';
      type = types.deferredModule;
      default = { };
    };

    extraBaseModules = mkOption {
      description = ''
        NixOS configuration that, like [{option}`defaults`](#test-opt-defaults), is applied to all [{option}`nodes`](#test-opt-nodes) and can not be undone with [`specialisation.<name>.inheritParentConfig`](https://search.nixos.org/options?show=specialisation.%3Cname%3E.inheritParentConfig&from=0&size=50&sort=relevance&type=packages&query=specialisation).
      '';
      type = types.deferredModule;
      default = { };
    };


    nodes = mkOption {
      type = types.attrsOf (types.submodule ({ name, config, ... }: {
        options.nixpkgsPath = mkOption {
          type = types.path;
          default = hostPkgs.path;
          description = "Path to the toplevel of nixpkgs required to eval";
          longDescription = ''
            This is needed to allow for the import module-list to match the intended
            checkout of nixpkgs associated with the modules setting downstream options.
          '';
        };

        options.specialArgs = mkOption {
          type = types.attrsOf types.any;
          default = testModuleArgs.specialArgs;
          description = "Attrset of values passed to evalModules' specialArgs paramter";
        };

        options.modules = mkOption {
          type = types.listOf types.deferredModules;
          default = [ ];
          description = "Additional modules to be passed to node evaluation";
        };

        options.machine = mkOption {
          type = types.raw;
          default = types.option;
          internal = true;
        };

        config.machine = mkNode config;
      }));
    };
  };

  config = {
    _module.args.nodes = config.nodes;
    passthru.nodes = config.nodes;
  };
}
