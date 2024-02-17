{ pkgs-23_11, config, settings, ... }: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot.kernelPackages = pkgs-23_11.linuxPackages_zen;
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
  boot.plymouth = {
    enable = true;
    theme = "fade-in";
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
      package = config.boot.kernelPackages.nvidiaPackages.vulkan_beta;
    };
  };

  # compress nix store
  fileSystems."/nix/store".options = [ "compress-force=zstd" ];

  # system
  networking.hostName = "hamilton";

  # state versions
  system.stateVersion = "22.11";
  home-manager.users.${settings.user.name}.home.stateVersion = "22.11";
}
