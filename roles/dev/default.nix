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
    ];
  };
}
