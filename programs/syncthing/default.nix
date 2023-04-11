user: { config, lib, ... }:

let
  devices = {
    mobai = { id = "746EZ7Y-TFBI5H2-ITXQ2YO-PYRVMEW-MFOYP5W-HVKVWDP-SLNMRPU-ECAJIQ5"; introducer = true; };
  };
  folders = {
    "Secret" = {
      id = "0hhw6-hojo4";
      devices = [ "mobai" ];
      path = "${user.home}/.secret";
      enable = true;
    };
  };
in
with lib; {
  config.services.syncthing = {
    enable = true;
    overrideDevices = false; # allow introductions
    overrideFolders = true;
    inherit devices folders;
  };

  config.users.users = mkIf (config.services.syncthing.enable) {
    ${user.name}.extraGroups = [ "syncthing" ];
    syncthing.extraGroups = [ "users" ];
  };

  config.systemd.tmpfiles.rules = mkIf (config.services.syncthing.enable) ([
    "d /var/lib/syncthing 0770 syncthing syncthing"
    "d /var/lib/syncthing/config 0770 syncthing syncthing"
    "d ${user.home} 0750 ${user.name} syncthing"
  ] ++
  # Additionally set sticky bit for syncthing group ownership of folders
  (builtins.map (folder: "d ${folder.path} 1770 ${user.name} syncthing")
    (builtins.attrValues folders)));

  config.systemd.services.syncthing.serviceConfig.UMask = mkIf (config.services.syncthing.enable) "0007";
}
