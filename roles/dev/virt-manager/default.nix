{ pkgs, settings, ... }:
let
  module = {
    dconf.settings."org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };
in
{
  home-manager.users.${settings.user.name} = {
    imports = [ module ];
    home.packages = [
      pkgs.virt-manager
    ];
  };
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;
}
