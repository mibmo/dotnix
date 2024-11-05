{ lib, pkgs, ... }: {
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
      duf
      dwarfs
      ffmpeg
      file
      gnumake
      insomnia
      killall
      ldns
      libqalculate
      lsof
      mktemp
      mmv-go
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
    groups = [
      # talk directly to usb and serial devices
      "dialout"
      "uucp"
    ];
    settings = {
      programs = {
        bottom.enable = true;
        fastfetch.enable = true;
        fd.enable = true;
        fzf.enable = true;
        gh = {
          enable = true;
          settings.git_protocol = "ssh";
          extensions = [ pkgs.gh-notify ];
        };
        htop = {
          enable = true;
          settings = {
            tree_view = true;
          };
        };
        hyfetch.enable = true;
        jq.enable = true;
        ripgrep.enable = true;
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
    mtr.enable = true;
    nix-index = {
      enable = true;
      enableBashIntegration = lib.mkDefault false;
      enableFishIntegration = lib.mkDefault false;
      enableZshIntegration = lib.mkDefault false;
    };
  };

  persist.user.directories = [
    ".cache/nix-index"
  ];
}
