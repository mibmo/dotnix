{ config, ... }:
{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    enableNvidia = builtins.any (vd: vd == "nvidia") config.services.xserver.videoDrivers;
  };
}
