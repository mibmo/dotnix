{ lib, config, settings, ... }:
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
    persistentStoragePath = "/persist";
    directories = cfg.directories ++ [
      "/var/log"
      "/var/logs"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
    ];
    files = cfg.files ++ [
      "/etc/machine-id"
    ];

    users.${settings.user.name} = {
      directories = [
        "assets"
        "backup"
        "dev"
        "games"
        { directory = ".ssh"; mode = "0700"; }
      ];
    };
  };
}
