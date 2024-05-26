{ lib, pkgs, ... }: {
  imports = [
    ./dns.nix
    ./vpn.nix
    ./auto-authenticate.nix
  ];

  networking = {
    firewall.enable = false;
    networkmanager = {
      enable = true;
      settings.device-p2p = {
        match-device = "interface-name:p2p-dev-*";
        managed = false;
      };
    };
  };

  home.groups = [ "networkmanager" ];

  persist.directories = [{
    directory = "/etc/NetworkManager/system-connections";
    user = "root";
    group = "root";
  }];
}
