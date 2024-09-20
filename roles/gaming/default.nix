{ inputs, lib, pkgs, settings, ... }: {
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
    groups = [ "gamemode" "gamescope" ];
    packages = with pkgs; [
      lutris
      prismlauncher
      wineWowPackages.waylandFull
    ];
    settings.programs.mangohud.enable = true;
  };

  environment.systemPackages = with pkgs; [
    dxvk
    vkd3d
  ];

  persist.user.directories = [
    ".local/share/Steam"
    ".local/share/lutris"
    ".steam"
    "games"
  ];
}
