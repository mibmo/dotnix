{ config, pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      docker-compose
      kubectl
      kind
    ];
    groups = [
      "podman"
      "docker"
    ];
  };
  virtualisation = {
    containers.enable = true;
    docker.enable = true;
    /*
      podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      # enable host zfs support
      extraPackages = [ pkgs.zfs ];
      };
    */
  };

  hardware.nvidia-container-toolkit.enable = builtins.any (
    vd: vd == "nvidia"
  ) config.services.xserver.videoDrivers;

  persist = {
    directories = [ "/var/lib/rancher/k3s" ];
    user = {
      directories = [ ".local/share/containers" ];
      files = [ ".kube/config" ];
    };
  };
}
