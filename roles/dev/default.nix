{ config, pkgs, ... }:
{
  imports = [
    ./git
    ./shell
    ./neovim
    ./terminal
    ./android
    ./containers
    ./virtualisation
    ../internet/tor
    ../internet/i2p
  ];

  home = {
    packages = with pkgs; [
      aria2
      arp-scan
      bat
      (curlFull.override {
        c-aresSupport = true;
        http3Support = true;
      })
      duf
      dwarfs
      ffmpeg
      file
      gnumake
      killall
      ldns
      libjxl
      libqalculate
      lsof
      lurk
      mktemp
      mmv-go
      nix-output-monitor
      nix-tree
      nixpkgs-review
      nvd
      p7zip-rar
      pciutils
      pv
      sshfs
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
      # access network interface
      "netdev"
      # allow capuring packets with wireshark
      "wireshark"
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
          matchBlocks = {
            "*" = {
              forwardAgent = false;
              addKeysToAgent = "no";
              compression = false;
              serverAliveInterval = 0;
              serverAliveCountMax = 3;
              hashKnownHosts = false;
              userKnownHostsFile = "~/.ssh/known_hosts";
              controlMaster = "no";
              controlPath = "~/.ssh/master-%r@%n:%p";
              controlPersist = "no";
            };
            onion = {
              host = "*.onion";
              proxyCommand = "nc -X 5 -x localhost:${toString config.services.tor.client.socksListenAddress.port} %h %p";
            };
            kanpai = {
              host = "*.kanpai";
              port = 12248;
              # for now, just use root
              user = "root";
            };
          };
        };
        tmux.enable = true;
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

    # nix-index and command-not-found are not compatible; prefer nix-index
    command-not-found.enable = false;
    nix-index = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };
    wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
  };

  persist.user.directories = [
    ".cache/nix-index"
    ".config/DevDocs"
  ];
}
