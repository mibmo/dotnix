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
      ffmpeg
      duf
      imv
      mktemp
      which
      nix-index
      ldns
      neofetch
      killall
      insomnia
      htop
      gnumake
      tree
      libqalculate
      fzf
      drawio
      mmv-go
      jq
      dwarfs
      nix-output-monitor
      nvd
      github-cli
      p7zip
      zip
      unzip
      ripgrep
      fd
      file
      lsof
      arp-scan
    ];
    groups = [ "uucp" "dialout" ];
    settings = {
      programs = {
        fzf.enable = true;
        bottom.enable = true;
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

  persist.user.directories = [ "dev" ];
}
