{
  config,
  lib,
  pkgs,
  ...
}:
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

  # forward active vpn's dns servers while enabled
  networking.networkmanager.dispatcherScripts = [
    {
      type = "pre-up";
      source = lib.getExe (
        pkgs.writeShellApplication {
          name = "vpnUpDnsHook";
          runtimeInputs = with pkgs; [
            unbound
            networkmanager
            perl
          ];
          text = ''
            log() { echo "[vpn]" "$@"; }

            if [[ "$DEVICE_IFACE" == wg-* ]] && [ "$2" = "pre-up" ]; then
              log "starting dns forward of $CONNECTION_ID"

              nameservers="$(nmcli --terse con show "$CONNECTION_UUID" | perl -nle 'print "$1" if /^ipv[46]\.dns:(.*)$/s' 2>/dev/null)"
              log "found nameservers: $nameservers"
              if unbound-control forward "$nameservers" >/dev/null 2>&1;
                then log "started forwarding vpn nameservers"
                else log "failed to forward vpn nameservers"
              fi
            fi
          '';
        }
      );
    }
    {
      type = "pre-down";
      source = lib.getExe (
        pkgs.writeShellApplication {
          name = "vpnDownDnsHook";
          runtimeInputs = with pkgs; [
            unbound
          ];
          text = ''
            log() { echo "[vpn]" "$@"; }

            if [[ "$DEVICE_IFACE" == wg-* ]] && [ "$2" = "pre-down" ]; then
              log "stopping dns forward of $CONNECTION_ID"

              if unbound-control forward off 1>/dev/null 2>&1;
                then log "stopped forwarding vpn nameservers"
                else log "failed to stop forward vpn nameservers"
              fi
            fi
          '';
        }
      );
    }
  ];

  persist.directories = [
    {
      directory = cfg.stateDir;
      inherit (cfg) user group;
      mode = "u=rw,g=,o=";
    }
  ];
}
