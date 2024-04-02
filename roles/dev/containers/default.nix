{ config, ... }: {
  home.groups = [ "podman" ];
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
    enableNvidia = builtins.any (vd: vd == "nvidia") config.services.xserver.videoDrivers;
  };
}
