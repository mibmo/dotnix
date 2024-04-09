{ lib, config, settings, ... }:
let
  inherit (settings.user) name;
  home = "/home/${name}";

  cfg = config.services.syncthing;

  devices = import ./devices.nix;
  folders = import ./folders.nix { inherit home; };
in
with lib; {
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    overrideDevices = false; # allow introductions
    overrideFolders = true;
    settings = { inherit devices folders; };
    key = config.age.secrets.syncthing-key.path;
    cert = config.age.secrets.syncthing-cert.path;
    dataDir = home;

    # @TODO: run as syncthing user and handle permissions properly
    user = name;
    group = "users";
  };

  age.secrets =
    let
      getSecret = type: "${../../../secrets}/syncthing_${config.networking.hostName}_${type}";
    in
    {
      syncthing-key.file = getSecret "key";
      syncthing-cert.file = getSecret "cert";
    };
}
