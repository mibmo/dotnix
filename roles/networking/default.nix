{ lib, pkgs, ... }: {
  imports = [
    ./dns.nix
    ./vpn.nix
    ./auto-authenticate.nix
  ];

  networking = {
    firewall.enable = false;
    networkmanager.enable = true;
  };

  home.groups = [ "networkmanager" ];

  persist.directories = [{
    directory = "/etc/NetworkManager/system-connections";
    user = "root";
    group = "root";
  }];
}
