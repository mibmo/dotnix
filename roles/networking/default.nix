{ settings, ... }: {
  networking = {
    firewall.enable = false;
    networkmanager = {
      enable = true;
      insertNameservers = [
        "9.9.9.9"
        "149.112.112.112"
        "2620:fe::fe"
        "2620:fe::9"
      ];
    };
  };

  users.users.${settings.user.name}.extraGroups = [ "networkmanager" ];
}
