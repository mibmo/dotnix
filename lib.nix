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

  # read directory, producing attribute set where child sets represent
  # directories and leaf nodes are strings with their filesystem types
  loadDirectory = readDirectoryIntoAttrs [ ];
  readDirectoryIntoAttrs = dirs: directory:
    let
      path = dirs ++ [ directory ];
      dirPath = concatStringsSep "/" path;
    in
    mapAttrs
      (name: type: {
        regular = "file";
        directory = readDirectoryIntoAttrs path name;
      }.${type} or type)
      (readDir dirPath);

  # prune intersect attribute sets for merging.
  # returns a set comparing source and destination where:
  #  - attributes present only in source are null
  #  - attributes present only in destination are ignored
  #  - attributes present in both favor the destination
  #  - childsets present only in source are null
  #  - childsets present only in destination are ignored
  #  - childsets present in both are recursively handled,
  #      applying the above logic to both childsets
  #
  # pruneIntersectedAttrs
  # {
  #   both = "hello";
  #   sourceAttr = "coming!";
  #   recurse.source = "src";
  #   onlyInSource.whatever = "whatever";
  # }
  # {
  #   both = "there";
  #   destinationAttr = "here!";
  #   recurse.destination = "dest";
  #   onlyInDest.whatever = "whatever";
  # }
  # returns
  # {
  #   both = "there";
  #   sourceAttr = "none";
  #   recurse.source = "none";
  #   onlyInSource = "none";
  # }
  pruneIntersectedAttrs = default: source: destination:
    mapAttrs
      (name: value:
        let
          attr = attrByPath [ name ] default destination;
        in
        if typeOf attr == "set"
        then pruneIntersectedAttrs default source.${name} destination.${name}
        else
          if attr == default then attr else value
      )
      source;

  combined-lib = nixpkgs-lib // lib;

  lib = {
    inherit noop recurse recurseTransform mkModule loadDirectory pruneIntersectedAttrs;
  };
in
lib
