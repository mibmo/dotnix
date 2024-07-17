{ inputs, ... }:
let
  nixpkgs-lib = inputs.nixpkgs.lib;
  inherit (nixpkgs-lib.attrsets) attrByPath collect foldlAttrs
    genAttrs mapAttrs mapAttrsRecursive optionalAttrs;
  inherit (nixpkgs-lib.strings) concatStringsSep hasPrefix removePrefix;
  inherit (builtins) typeOf readDir;

  noop = a: a;

  recurse = recurseTransform noop;

  recurseTransform = transform: pred: f: set:
    builtins.mapAttrs
      (name: value:
        if pred value
        then f value
        else recurse pred f (transform value)
      )
      set;

  mkModule = module: args@{ pkgs, ... }: {
    imports = with inputs; [
      ({ ... }: {
        nixpkgs = {
          config.allowUnfree = true;
          overlays = import ./overlays/default.nix { lib = nixpkgs-lib; };
        };
      })
      ./modules
      module.host
    ] ++ module.roles;

    _module.args =
      let
        # "release" = [ "pkgs-0.1.0" "to-0.2.0" "allow-0.3.0];
        # i.e. `"23.11" = [ "hello-2.12.1" ];`
        permittedInsecurePackages = { };
      in
      {
        inherit inputs;
        host = module;
        settings = import ./config.nix { inherit inputs pkgs; lib = combined-lib; };
        lib = combined-lib;
      } // foldlAttrs
        (acc: name: input: acc // optionalAttrs
          (hasPrefix "nixpkgs-" name)
          {
            ${removePrefix "nix" name} =
              let
                version = removePrefix "nixpkgs-" name;
              in
              if !permittedInsecurePackages ? ${version}
              then input.legacyPackages.${module.system}
              else
                import input {
                  inherit (module) system;
                  config.permittedInsecurePackages = permittedInsecurePackages.${version};
                };
          }
        )
        { }
        inputs;
  };

  combined-lib = nixpkgs-lib // lib;

  lib = {
    inherit noop recurse recurseTransform mkModule;
  };
in
lib
