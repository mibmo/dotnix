{ lib, config, ... }:
with lib;
let
  cfg = config.persist;
in
{
  # reimplement persistence without worrying about different "stores"
  options.persist = {
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
  };

  config.environment.persistence.main = {
    # avoid infinite recursion; adds a little hassle when configuring hosts
    enable = mkDefault false;
    inherit (cfg) directories files;
  };
}
