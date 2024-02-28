{ lib, pkgs, settings, ... }: {
  imports = [
    ./dns.nix
    ./vpn.nix
  ];

  networking = {
    firewall.enable = false;
    networkmanager = {
      enable = true;
      dispatcherScripts = map
        ({ name, ap-name, effect }: {
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
        }) [
        {
          name = "dsbwifi";
          ap-name = ".DSB_Wi-Fi";
          effect = ''
            ${lib.getExe pkgs.curl} \
                --silent \
                --insecure \
                --connect-timeout 2 \
                --header 'Host: dsbwifi.dk' \
                --form 'language=dk' \
                "https://$IP4_GATEWAY/login.php"
          '';
        }
      ];
    };
  };

  users.users.${settings.user.name}.extraGroups = [ "networkmanager" ];
}
