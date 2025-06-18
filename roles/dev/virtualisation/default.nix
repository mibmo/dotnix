{ pkgs, ... }:
{
  home = {
    packages = [ pkgs.virt-manager ];
    groups = [ "libvirtd" ];
    settings.dconf.settings."org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };
  virtualisation = {
    libvirtd.enable = true;
    waydroid.enable = true;
  };
  programs.dconf.enable = true;
  networking.firewall.trustedInterfaces = [ "virbr0" ];
  persist = {
    directories = [ "/var/lib/libvirt" ];
    user.directories = [ ".local/share/waydroid" ];
  };
}
