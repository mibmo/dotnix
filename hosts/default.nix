{
  lib,
  specification,
  ...
}:
let
  inherit (lib.attrsets) collect;
  inherit (lib.lists) fold;
in
fold (host: acc: acc // { ${host.name} = lib.dot.mkSystem host; }) { } (
  collect (c: c ? name) specification.hosts
)
