{ lib, pkgs, config, settings, ... }:
let
  module = {
    programs = {
      fzf.enable = true;
      bottom.enable = true;
      htop = {
        enable = true;
        settings = {
          tree_view = true;
        };
      };
    };
  };
in
{
  imports = [
    ./git
    ./fish
    ./neovim
    ./alacritty
    ./android
    ./containers
    ./virt-manager
  ];

  home-manager.users.${settings.user.name} = {
    imports = [ module ];
    home.packages = with pkgs; [
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
    ];
  };

  users.users.${settings.user.name}.extraGroups = [ "uucp" "dialout" ];

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
}
