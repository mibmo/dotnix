{ inputs, pkgs, settings, ... }: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    enableCryptodisk = true;
  };
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/f413ce65-cc29-4fe8-9ced-9ad2e1c0d233";
      preLVM = true;
    };
  };

  # video
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware = {
    opengl = {
      enable = true;
      driSupport32Bit = true;
    };
    nvidia = {
      modesetting.enable = true;
      prime.offload.enable = true;
    };
  };

  # system
  networking.hostName = "hamilton";
  
  # state versions
  system.stateVersion = "22.11";
  home-manager.users.${settings.user.name}.home.stateVersion = "22.11";
}
