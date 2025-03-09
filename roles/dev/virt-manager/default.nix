{ pkgs, ... }:
{
  home = {
    packages = [ pkgs.virt-manager ];
    settings.dconf.settings."org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;
  persist.directories = [ "/var/lib/libvirt" ];
}
