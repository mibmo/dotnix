{ lib, config, settings, ... }:
let
  inherit (settings.user) name;
  home = "/home/${name}";

  cfg = config.services.syncthing;

  devices = import ./devices.nix;
  folders = import ./folders.nix { inherit home; };
in
with lib; {
  config.services.syncthing = {
    enable = true;
    overrideDevices = false; # allow introductions
    overrideFolders = true;
    settings = { inherit devices folders; };
  };

  config.users.users = mkIf (cfg.enable) {
    ${name}.extraGroups = [ cfg.group ];
    ${cfg.user}.extraGroups = [ "users" ];
  };

  config.systemd.tmpfiles.rules = mkIf (config.services.syncthing.enable) ([
    "d ${cfg.dataDir} 0770 ${cfg.user} ${cfg.group}"
    "d ${cfg.configDir} 0770 ${cfg.user} ${cfg.group}"
    "d ${home} 0750 ${name} ${cfg.user}"
  ] ++
  # Additionally set sticky bit for syncthing group ownership of folders
  (builtins.map (folder: "d ${folder.path} 1770 ${name} ${cfg.group}")
    (builtins.attrValues folders)));

  config.systemd.services.syncthing.serviceConfig.UMask = mkIf (config.services.syncthing.enable) "0007";
}
