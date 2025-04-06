{ config, ... }:
let
  cfg = config.services.unbound;

  tailscale-stub-zones = [
    "mib"
    "kanpai"
  ];
in
{
  environment.etc."resolv.conf".text = ''
    nameserver 127.0.0.1
    nameserver ::1
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
        # send as little information as possible to upstream servers (for privacy reasons)
        qname-minimisation = false;
        # require DNSSEC data for trust-anchored zones
        harden-dnssec-stripped = true;
        # keep probing servers that are down
        infra-keep-probing = true;
        # prefetch entries about to expire (10% of TTL left)
        prefetch = true;
        # dont cache empty responses
        cache-max-negative-ttl = 5;

        # increase cache size
        rrset-cache-size = "400m";
        msg-cache-size = "200m";
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

  persist.directories = [
    {
      directory = cfg.stateDir;
      inherit (cfg) user group;
      mode = "u=rw,g=,o=";
    }
  ];
}
