{
  lib,
  config,
  settings,
  ...
}:
let
  inherit (lib) mkOption types;
  cfg = config.home;
in
{
  options.home = {
    groups = mkOption {
      type = with types; listOf str;
      default = [ ];
      description = lib.mdDoc "Groups for user";
    };

    packages = mkOption {
      type = with types; listOf package;
      default = [ ];
      description = lib.mdDoc "Packages for user. Added through home-manager";
    };

    environment = mkOption {
      type =
        with types;
        lazyAttrsOf (oneOf [
          str
          path
          int
          float
        ]);
      default = { };
      description = lib.mdDoc "Environment variables set for user";
    };

    settings = mkOption {
      type = with types; deferredModule;
      default = { };
      description = lib.mdDoc "Alias to home-manager options for user";
    };
  };

  config = {
    users = {
      users.${settings.user.name}.extraGroups = cfg.groups;
      groups = lib.genAttrs cfg.groups (_: { });
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;

      # also fixes issue with fcitx5's profile file
      backupFileExtension = "backup";

      # use same state version across root and user
      users.root.home.stateVersion = config.home-manager.users.${settings.user.name}.home.stateVersion;

      users.${settings.user.name} = {
        news.display = "silent";
        imports = [ cfg.settings ];
        home = {
          inherit (cfg) packages;
          sessionVariables = {
            EDITOR = settings.defaults.editor;
          } // cfg.environment;
        };
      };
    };
  };
}
