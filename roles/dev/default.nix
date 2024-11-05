{ lib, pkgs, config, ... }: {
  imports = [
    ./git
    ./shell
    ./neovim
    ./terminal
    ./android
    ./containers
    ./virt-manager
    ../internet/tor
    ../internet/i2p
  ];

  home = {
    packages = with pkgs; [
      arp-scan
      drawio
      duf
      dwarfs
      fd
      ffmpeg
      file
      fzf
      github-cli
      gnumake
      htop
      imv
      insomnia
      jq
      killall
      ldns
      libqalculate
      lsof
      mktemp
      mmv-go
      nix-index
      nix-output-monitor
      nvd
      p7zip
      pciutils
      tree
      unzip
      usbutils
      which
      zip
    ];
    groups = [ "uucp" "dialout" ];
    settings = {
      programs = {
        fzf.enable = true;
        bottom.enable = true;
        ripgrep.enable = true;
        fastfetch.enable = true;
        hyfetch.enable = true;
        htop = {
          enable = true;
          settings = {
            tree_view = true;
          };
        };
        ssh = {
          enable = true;
          serverAliveInterval = 60;
        };
      };
    };
  };

  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "armv6l-linux"
    "riscv32-linux"
    "riscv64-linux"
  ];

  programs = {
    nix-index = {
      enable = true;
      enableZshIntegration = lib.mkDefault false;
      enableFishIntegration = lib.mkDefault false;
      enableBashIntegration = lib.mkDefault false;
    };

    mtr.enable = true;
  };
}
