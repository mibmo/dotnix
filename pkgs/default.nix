{
  inputs,
  lib,
  pkgs,
  system,
  ...
}:
let
  inherit (lib.dot) traverse;
  inherit (lib.attrsets) collect listToAttrs;
  inherit (lib.lists) last;
  inherit (lib.strings) concatStringsSep;

  callPackage = lib.callPackageWith (pkgs // { inherit inputs system; });
in
# traverse directory tree recursively, filtering out files except
# those that are named `package.nix`, which are then turned into
# a name-value pair where the name is that of the parent
# directory and the value evaluates to the package.
listToAttrs (
  collect (set: set ? "name" && set ? "value") (
    traverse {
      regular =
        { path, name }:
        if name == "package.nix" then
          {
            name = last path;
            value = callPackage (concatStringsSep "/" path + "/package.nix") { };
          }
        else
          null;
    } [ ./. ]
  )
)
