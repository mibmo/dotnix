{ lib, pkgs, ... }:
let
  templates = {
    mermaid =
      args@{
        name,
        ap-name ? args.name,
      }:
      {
        inherit name ap-name;
      };
  };

  curlPkg = pkgs.curlFull.override {
    # for --dns-servers
    c-aresSupport = true;
  };
  curl = ''
    ${lib.getExe curlPkg} \
      --connect-timeout 8 \
      --dns-servers $IP4_NAMESERVERS \
      --insecure \
      --silent \
  '';
in
{
  networking.networkmanager.dispatcherScripts =
    map
      (
        {
          name,
          ap-name,
          effect,
        }:
        {
          type = "basic";
          source = pkgs.writeShellScript "testHook" ''
            log() {
              logger "[${name}]" "$@"
            }

            if [ "$2" = "up" ] && [ "$CONNECTION_ID" = "${ap-name}" ]; then
              log "attempting login to $CONNECTION_ID via $IP4_GATEWAY"

              if (${effect});
                then log "login successful"
                else log "login failed"
              fi
            fi
          '';
        }
      )
      [
        {
          name = "dsbwifi";
          ap-name = "DSB_Wi-Fi";
          effect = ''
            ${curl} \
                --header 'Host: dsbwifi.dk' \
                --form 'language=dk' \
                "https://$IP4_GATEWAY/login.php"
          '';
        }
      ];
}
