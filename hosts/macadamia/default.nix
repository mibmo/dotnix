{ lib, pkgs, config, settings, modulesPath, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/hardware/network/broadcom-43xx.nix")
    ./disks.nix
  ];

  # boot
  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "nvme" "ahci" "usbhid" "usb_storage" "sd_mod" ];
    kernelModules = [ "kvm-intel" ];
    kernelPackages = pkgs.linuxPackages_zen;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
      };
    };

    zfs.package = pkgs.zfs_unstable;

    plymouth = {
      enable = true;
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

  # power management
  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  # system
  networking = {
    hostName = "macadamia";
    hostId = "dafee86f";
  };
  hardware.cpu.intel.updateMicrocode = true;
  environment.persistence.main.enable = true;

  # state versions
  system.stateVersion = "23.11";
  home-manager.users.${settings.user.name}.home.stateVersion = "23.11";
}
