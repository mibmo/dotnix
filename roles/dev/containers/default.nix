{ config, ... }: {
  home.groups = [ "podman" ];
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
  };

  hardware.nvidia-container-toolkit.enable =
    builtins.any
      (vd: vd == "nvidia")
      config.services.xserver.videoDrivers;

  persist.user.directories = [
    ".local/share/containers"
  ];
}
