{ lib, ... }:
{
  imports = map (lib.path.append ./.) (
    lib.attrsets.attrNames (lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./.))
  );
}
