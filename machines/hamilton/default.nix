{ config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    version = 2;
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
  hardware.opengl.enable = true;

  # system
  networking.hostName = "hamilton";
}
