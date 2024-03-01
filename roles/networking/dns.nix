{ config, ... }:
let
  tailscale-stub-zones = [
    "mib"
    "kanpai"
  ];
in
{
  networking.networkmanager.dns = "unbound";

  services.unbound = {
    enable = true;
    settings = {
      server = {
        # bind to ipv{4,6} loopback
        ip-address = [ "127.0.0.1" "::1" ];
        # nameservers already do this
        qname-minimisation = false;
      };

      forward-zone = [
        {
          name = ".";
          forward-addr = [
            "9.9.9.9"
            "149.112.112.112"
            "2620:fe::fe"
            "2620:fe::9"
          ];
        }
      ];

      domain-insecure = config.networking.timeServers ++ tailscale-stub-zones;
      stub-zone = map
        (name: {
          inherit name;
          stub-addr = [ "100.100.100.100" "fd7a:115c:a1e0::53" ];
        })
        tailscale-stub-zones;
    };
  };
}
