{ config, ... }:
let
  cfg = config.services.kubo;
in
{
  services.kubo = {
    enable = true;
    enableGC = true;
    localDiscovery = true;
    autoMigrate = true;
    #autoMount = true;
    settings = {
      Addresses.API = [
        "/ip4/127.0.0.1/tcp/5001"
        "/ip6/::1/tcp/5001"
      ];
    };
  };

  home.groups = [ cfg.group ];
}
