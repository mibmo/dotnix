{ config, ... }:
let
  tailscale-stub-zones = [
    "mib"
    "kanpai"
  ];
in
{
  environment.etc."resolv.conf".text = ''
    nameserver 127.0.0.1
    options edns0 trust-ad
  '';

  services.unbound = {
    enable = true;
    enableRootTrustAnchor = true;
    settings = {
      server = {
        # bind to ipv{4,6} loopback
        ip-address = [
          "127.0.0.1"
          "::1"
        ];
        # nameservers already do this
        qname-minimisation = false;
      };

      remote-control = {
        control-enable = true;
        control-use-cert = false;
      };

      domain-insecure = config.networking.timeServers ++ tailscale-stub-zones;
      stub-zone = map (name: {
        inherit name;
        stub-addr = [
          "100.100.100.100"
          "fd7a:115c:a1e0::53"
        ];
      }) tailscale-stub-zones;
    };
  };
}
