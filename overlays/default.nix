{ lib }:
builtins.map (path: import (./. + "/${path}")) (
  builtins.filter (name: name != "default.nix") (lib.attrsets.attrNames (builtins.readDir ./.))
)
