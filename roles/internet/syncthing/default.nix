{ lib, config, settings, ... }:
let
  inherit (settings.user) name;
  home = "/home/${name}";

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

  config.users.users = mkIf (config.services.syncthing.enable) {
    ${name}.extraGroups = [ "syncthing" ];
    syncthing.extraGroups = [ "users" ];
  };

  config.systemd.tmpfiles.rules = mkIf (config.services.syncthing.enable) ([
    "d /var/lib/syncthing 0770 syncthing syncthing"
    "d /var/lib/syncthing/config 0770 syncthing syncthing"
    "d ${home} 0750 ${name} syncthing"
  ] ++
  # Additionally set sticky bit for syncthing group ownership of folders
  (builtins.map (folder: "d ${folder.path} 1770 ${name} syncthing")
    (builtins.attrValues folders)));

  config.systemd.services.syncthing.serviceConfig.UMask = mkIf (config.services.syncthing.enable) "0007";
}
