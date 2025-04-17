{ lib, pkgs, ... }:
{
  imports = [
    ./dns.nix
    ./vpn.nix
    ./auto-authenticate.nix
  ];

  networking = {
    firewall.enable = true;
    nftables.enable = true;
    networkmanager = {
      enable = true;
      settings.device-p2p = {
        match-device = "interface-name:p2p-dev-*";
        managed = false;
      };
    };
  };

  systemd.services.NetworkManager-wait-online.serviceConfig.ExecStart = [
    ""
    "${lib.getExe' pkgs.networkmanager "nm-online"} -q"
  ];

  home.groups = [ "networkmanager" ];

  persist.directories = [
    {
      directory = "/etc/NetworkManager/system-connections";
      user = "root";
      group = "root";
    }
  ];
}
