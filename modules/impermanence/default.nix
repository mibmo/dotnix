{ lib, config, settings, ... }:
with lib;
let
  inherit (lists) unique;

  cfg = config.persist;
in
{
  # reimplement persistence without worrying about different "stores"
  options.persist = {
    directories = mkOption {
      type = with types; listOf (coercedTo str (d: { directory = d; }) attrs);
      description = "Directories to persist";
    };

    files = mkOption {
      type = with types; listOf (coercedTo str (f: { file = f; }) attrs);
      description = "Files to persist";
    };

    user = {
      directories = mkOption {
        type = with types; listOf (coercedTo str (d: { directory = d; }) attrs);
        description = "Directories to persist for primary user";
      };

      files = mkOption {
        type = with types; listOf (coercedTo str (f: { file = f; }) attrs);
        description = "Files to persist for primary user";
      };
    };
  };

  config = {
    environment.persistence.main = {
      # avoid infinite recursion; adds a little hassle when configuring hosts
      enable = mkDefault false;
      persistentStoragePath = "/persist";

      directories = unique cfg.directories;
      files = unique cfg.files;
      users.${settings.user.name} = {
        directories = unique cfg.directories;
        files = unique cfg.files;
      };
    };

    persist = {
      directories = lib.mkAfter [
        "/var/log"
        "/var/logs"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
      ];
      files = lib.mkAfter [
        "/etc/machine-id"
      ];
      user = {
        directories = lib.mkAfter [
          "assets"
          "backup"
          { directory = ".ssh"; mode = "0700"; }
        ];
        files = lib.mkAfter [ ];
      };
    };
  };
}
