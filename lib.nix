{ inputs, ... }:
let
  inherit (inputs.nixpkgs.lib) attrsets;

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

  mkModule = module:
    args@{ ... }: {
      imports = with inputs; [
        ({ ... }: {
          nixpkgs = {
            config.allowUnfree = true;
            overlays = import ./overlays/default.nix { inherit (inputs.nixpkgs) lib; };
          };
        })
        module.host
      ] ++ module.roles;

      _module.args = {
        inherit inputs args;
        host = module;
        modules = ../modules;
        settings = import ./config.nix { inherit inputs; lib = combined-lib; };
        lib = combined-lib;
      };
    };

  combined-lib = inputs.nixpkgs.lib // lib;

  lib = {
    inherit noop recurse recurseTransform mkModule;
  };
in
lib
