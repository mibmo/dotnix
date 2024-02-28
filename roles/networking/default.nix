{ lib, pkgs, settings, ... }: {
  imports = [
    ./dns.nix
    ./vpn.nix
    ./auto-authenticate.nix
  ];

  networking = {
    firewall.enable = false;
    networkmanager.enable = true;
  };

  users.users.${settings.user.name}.extraGroups = [ "networkmanager" ];
}
