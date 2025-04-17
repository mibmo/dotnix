{
  inputs,
  self,
  specification,
  ...
}:
let
  nixpkgs-lib = inputs.nixpkgs.lib;
  inherit (specification) permittedInsecurePackages permittedUnfreePatterns;

  inherit (nixpkgs-lib.attrsets)
    attrNames
    attrByPath
    collect
    filterAttrs
    genAttrs
    mapAttrs
    mapAttrs'
    mapAttrsRecursive
    recursiveUpdate
    mapAttrsRecursiveCond
    ;
  inherit (nixpkgs-lib.strings) concatStringsSep hasPrefix removePrefix;
  inherit (nixpkgs-lib.trivial) pipe;
  inherit (nixpkgs-lib) getName;
  inherit (nixpkgs-lib.customisation) callPackageWith;
  inherit (builtins)
    any
    head
    match
    typeOf
    readDir
    replaceStrings
    ;

  # exposed library functions
  dot = {
    inherit
      applyHosts
      isHost
      differingPaths
      inputNixpkgsToVersion
      loadDirectory
      mkHost
      mkPackageSets
      mkSystem
      nixpkgsInputs
      noop
      pruneIntersectedAttrs
      recurse
      mkDefaultEnableOption
      recurseTransform
      setIf
      ;
  };

  # final combined library
  lib = recursiveUpdate nixpkgs-lib { inherit dot; };

  # recursively finalize all specifications in `specification.nix` into hosts.
  applyHosts = mapAttrsRecursiveCond (s: !isHost s) mkHost;

  # requirements for being a valid host specification
  isHost = s: s ? "host";

  mkDefaultEnableOption =
    args:
    (nixpkgs-lib.options.mkEnableOption args)
    // {
      default = true;
    };

  # identity function
  # @TODO: deprecate in favor of `lib.trivial.id`
  noop = a: a;

  # set key in attribute set based on condition
  # usage: {
  #  ${setIf "favourites" hasFavourites} = favourites;
  # }
  setIf = key: cond: if cond then key else null;

  recurse = recurseTransform noop;

  recurseTransform =
    transform: pred: f: set:
    builtins.mapAttrs (
      name: value: if pred value then f value else recurse pred f (transform value)
    ) set;

  # turn `nixpkgs-24_05` into `24.05`
  inputNixpkgsToVersion = name: replaceStrings [ "_" ] [ "." ] (removePrefix "nixpkgs-" name);

  # nixpkgs inputs
  nixpkgsInputs = filterAttrs (name: _: hasPrefix "nixpkgs-" name) inputs;

  # release of nixpkgs that modules are built with
  # @TODO: isn't this actually just `inputNixpkgsToVersion inputs.nixpkgs.follows`?
  # @TODO: maybe rename to "systemNixpkgsRelease"?
  moduleNixpkgsVersion = pipe nixpkgsInputs [
    (filterAttrs (name: input: input.rev == inputs.nixpkgs.rev && name != "stable"))
    attrNames
    head
    inputNixpkgsToVersion
  ];

  # temporary var; will be attr of release-dependent overlays
  overlays = { }; # temp

  mkPackageSets =
    system:
    mapAttrs' (
      name: input:
      let
        version = inputNixpkgsToVersion name;
        hasInsecureOverride = permittedInsecurePackages ? ${version};
        hasUnfreeOverride = permittedUnfreePatterns ? ${version};
        hasOverlays = overlays ? ${version};
      in
      {
        name = inputNixpkgsToVersion name;
        value =
          if hasInsecureOverride || hasUnfreeOverride || hasOverlays then
            import input {
              inherit system;
              ${setIf "overlays" hasOverlays} = overlays.${version};
              config = {
                ${setIf "allowUnfreePredicate" hasUnfreeOverride} =
                  pkg: any (pattern: match pattern (getName pkg) != null) permittedUnfreePatterns.${version};
                ${setIf "permittedInsecurePackages" hasInsecureOverride} = permittedInsecurePackages.${version};
              };
            }
          else
            input.legacyPackages.${system};
      }
    ) nixpkgsInputs;

  # create package set from system.
  # used to inject own package and build tools
  mkPkgs =
    system:
    let
      nixpkgs = import inputs.nixpkgs {
        inherit system;
        overlays = import ../overlays { inherit lib; };
      };
      callPackage = callPackageWith (nixpkgs // pkgs);
      pkgs =
        nixpkgs
        // self.packages.${system}
        // {
          # @TODO: inject build tools
        };
    in
    pkgs;

  # make a system configuration given a host specification
  mkSystem =
    host:
    let
      # outside modules used by configuration
      externalModules = with inputs; [
        home-manager.nixosModules.home-manager
        disko.nixosModules.disko
        impermanence.nixosModules.impermanence
        nur.modules.nixos.default
        agenix.nixosModules.age
        hyprland.nixosModules.default
        stylix.nixosModules.stylix
      ];
      # custom modules
      customModules = ../modules;
      # add package sets
      packageSets = mkPackageSets host.system;
      packageArgs = mapAttrs' (name: value: {
        name = removePrefix "nix" name;
        inherit value;
      }) packageSets;

      module-pkgs = packageSets.${moduleNixpkgsVersion};
    in
    nixpkgs-lib.nixosSystem {
      inherit (host) system;
      specialArgs = packageArgs // {
        inherit
          host
          inputs
          lib
          specification
          ;
        #pkgs = mkPkgs host.system;
      };
      modules =
        externalModules
        ++ host.roles
        ++ [
          customModules
          host.host
          # @TODO: hack for compatability with many package sets
          {
            # inherit config and overlays from evaluating nixpkgs
            nixpkgs = {
              inherit (module-pkgs) config overlays;
            };

            _module.args = mapAttrs' (release: value: {
              name = "pkgs-${replaceStrings [ "." ] [ "_" ] release}";
              inherit value;
            }) packageSets;
          }
        ];
    };

  # finalize a host.
  mkHost =
    key: host:
    recursiveUpdate host {
      roles = host.roles or [ ] ++ [ ../roles/common ];
    };

  # read directory, producing attribute set where child sets represent
  # directories and leaf nodes are strings with their filesystem types
  loadDirectory = readDirectoryIntoAttrs [ ];
  readDirectoryIntoAttrs =
    dirs: directory:
    let
      path = dirs ++ [ directory ];
      dirPath = concatStringsSep "/" path;
    in
    mapAttrs (
      name: type:
      {
        regular = "file";
        directory = readDirectoryIntoAttrs path name;
      }
      .${type} or type
    ) (readDir dirPath);

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
  pruneIntersectedAttrs =
    default: source: destination:
    mapAttrs (
      name: value:
      let
        attr = attrByPath [ name ] default destination;
      in
      if typeOf attr == "set" then
        pruneIntersectedAttrs default source.${name} destination.${name}
      else if attr == default then
        attr
      else
        value
    ) source;

  # get paths to symlink when symlinking `source` into `destination` without
  # symlinking over any existing directories or files.
  # should be used in a process where symlinks in `destination` are cleaned up prior
  #
  # example:
  # when merging these two folders
  # a
  # ├── bin
  # │   └── foo.txt
  # ├── hello.txt
  # └── other
  #     ├── test.txt
  #     └── thingy.txt
  # b
  # ├── bin
  # │   └── bar.txt
  # └── world.txt
  #
  # the ideal merge would be
  # c
  # ├── bin (both a and b have `bin`, so recurse)
  # │   ├── bar.txt
  # │   └── foo.txt -> a/bin/foo.txt
  # ├── hello.txt -> a/hello.txt
  # ├── other -> a/other (no `other` in b, so symlink safe)
  # └── world.txt
  #
  # so the paths produced are [ "bin/foo.txt" "hello.txt" "other" ]
  differingPaths =
    source: destination:
    # collect paths
    collect (attr: typeOf attr == "string")
      # set leaf nodes to their path in the attribute set
      # discard if existing file
      (
        mapAttrsRecursive
          # pass "none" and "file" types (i.e. if path is non-existant in destination, or file exists in both)
          (
            path: type:
            (genAttrs [
              "none"
              "file"
            ] (_: concatStringsSep "/" path)).${type} or null
          )
          (pruneIntersectedAttrs "none" (loadDirectory source) (loadDirectory destination))
      );
in
lib
