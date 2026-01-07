{
  lib,
  specification,
  ...
}:
let
  inherit (lib.attrsets) collect;
  inherit (lib.lists) foldr;
in
foldr (host: acc: acc // { ${host.name} = lib.dot.mkSystem host; }) { } (
  collect (c: c ? name) specification.hosts
)
