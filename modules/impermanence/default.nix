# reimplement persistence without worrying about different "stores"
{
  config,
  lib,
  specification,
  ...
}:
let
  inherit (lib) types;
  inherit (lib.dot) mkDefaultEnableOption;
  inherit (lib.attrsets) hasAttrByPath mapAttrsToList recursiveUpdate;
  inherit (lib.lists)
    count
    foldl
    groupBy
    sortOn
    ;
  inherit (lib.modules) mkDefault;
  inherit (lib.options) mkOption;
  inherit (lib.trivial) id;

  cfg = config.persist;

  # count entropy of either a file or directory definition
  getEntropy =
    def:
    count id [
      (hasAttrByPath [ "force" ] def)
      # files
      (hasAttrByPath [ "user" ] def)
      (hasAttrByPath [ "group" ] def)
      (hasAttrByPath [ "mode" ] def)
      # directories
      (hasAttrByPath [ "parentDirectory" "user" ] def)
      (hasAttrByPath [ "parentDirectory" "group" ] def)
      (hasAttrByPath [ "parentDirectory" "mode" ] def)
    ];
  combineDuplicates =
    defs:
    mapAttrsToList (name: defs: foldl recursiveUpdate { } (sortOn getEntropy defs)) (
      groupBy (def: def.file or def.directory) defs
    );
in
{
  options.persist = {
    enable = mkDefaultEnableOption "Persistence";

    directories = mkOption {
      type = with types; listOf (coercedTo str (d: { directory = d; }) attrs);
      default = [ ];
      description = "Directories to persist";
    };

    files = mkOption {
      type = with types; listOf (coercedTo str (f: { file = f; }) attrs);
      default = [ ];
      description = "Files to persist";
    };

    user = {
      directories = mkOption {
        type = with types; listOf (coercedTo str (d: { directory = d; }) attrs);
        default = [ ];
        description = "Directories to persist for primary user";
      };

      files = mkOption {
        type = with types; listOf (coercedTo str (f: { file = f; }) attrs);
        default = [ ];
        description = "Files to persist for primary user";
      };
    };
  };

  config = {
    environment.persistence.main = lib.mkIf cfg.enable {
      # avoid infinite recursion
      enable = mkDefault true;
      persistentStoragePath = mkDefault "/persist";
      directories = combineDuplicates cfg.directories;
      files = combineDuplicates cfg.files;
      users.${specification.user.name} = {
        directories = combineDuplicates cfg.user.directories;
        files = combineDuplicates cfg.user.files;
      };
    };

    # disable impermanence when running in a VM. see nix-community/impermanence#262
    virtualisation.vmVariant.environment.persistence.main.enable = lib.mkForce false;
  };
}
