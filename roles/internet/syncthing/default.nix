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
    key = config.age.secrets.syncthing-hamilton-key.path;
    cert = config.age.secrets.syncthing-hamilton-cert.path;
    dataDir = home;

    # @TODO: run as syncthing user and handle permissions properly
    user = name;
    group = "users";
  };

  age.secrets = {
    syncthing-hamilton-key.file = ../../../secrets/syncthing_hamilton_key;
    syncthing-hamilton-cert.file = ../../../secrets/syncthing_hamilton_cert;
  };
}
