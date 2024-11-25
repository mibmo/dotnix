{
  inputs,
  lib,
  pkgs,
  settings,
  ...
}:
let
  extraPkgs =
    pkgs': with pkgs'; [
      dxvk
      keyutils
      libkrb5
      libpng
      libpulseaudio
      libvorbis
      stdenv.cc.cc.lib
      vkd3d
      xorg.libXScrnSaver
      xorg.libXcursor
      xorg.libXi
      xorg.libXinerama
    ];
in
{
  imports = [
    ./games.nix
  ];

  programs = {
    steam = {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      extraPackages = extraPkgs pkgs;
    };

    gamemode = {
      enable = true;
      settings.general.renice = 10;
    };

    gamescope = {
      enable = true;
      capSysNice = true;
    };
  };

  home = {
    groups = [
      "gamemode"
      "gamescope"
    ];
    packages = with pkgs; [
      (lutris.override { inherit extraPkgs; })
      prismlauncher
      rpcs3
      wineWowPackages.waylandFull
    ];
    settings.programs.mangohud.enable = true;
  };

  persist.user.directories = [
    ".config/rpcs3"
    ".local/share/Steam"
    ".local/share/etterna"
    ".local/share/lutris"
    ".steam"
    "games"
  ];
}
