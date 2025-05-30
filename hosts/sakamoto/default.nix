{
  pkgs,
  specification,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./disks.nix
    ./hardware.nix
  ];

  boot = {
    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "thunderbolt"
        "usb_storage"
        "usbhid"
        "sd_mod"
      ];
      systemd.enable = true;
    };
    kernelModules = [ "kvm-amd" ];
    kernelPackages = pkgs.linuxPackages_xanmod;
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
      };
      #systemd-boot.enable = true;
    };

    zfs.package = pkgs.zfs_unstable;

    plymouth = {
      enable = true;
      theme = "cuts"; # connect, cuts, pixels, sphere
      themePackages = with pkgs; [ adi1090x-plymouth-themes ];
    };
  };

  # video
  services.xserver.videoDrivers = [ ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # system
  system.stateVersion = "24.05";
  home-manager.users.${specification.user.name}.home.stateVersion = "24.05";
  networking = {
    hostName = "sakamoto";
    hostId = "e4c85bd0";
  };

  # amnesiac
  environment.persistence.main.enable = true;
}
