{ pkgs, config, settings, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./disks.nix
    ./hardware.nix
  ];

  boot = {
    initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "usbhid" "sd_mod" ];
    kernelModules = [ "kvm-amd" ];
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    loader = {
      efi.canTouchEfiVariables = true;
      /*
      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
      };
      */
      systemd-boot.enable = true;
    };

    zfs.package = pkgs.zfs_unstable;

    plymouth = {
      #enable = true;
      theme = "fade-in";
    };
  };

  # video
  services.xserver.videoDrivers = [ ];
  hardware = {
    opengl = {
      enable = true;
      driSupport32Bit = true;
    };
  };

  # system
  system.stateVersion = "24.05";
  home-manager.users.${settings.user.name}.home.stateVersion = "24.05";
  networking = {
    hostName = "sakamoto";
    hostId = "e4c85bd0";
  };

  # amnesiac
  environment.persistence.main.enable = true;
}
