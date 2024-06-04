{ pkgs, ... }: {
  programs = {
    steam = {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    gamemode = {
      enable = true;
      settings = {
        general.renice = 10;
        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          gpu_device = 0;
          amd_performance_level = "auto";
        };
      };
    };

    gamescope = {
      enable = true;
      capSysNice = true;
    };
  };

  home.packages = with pkgs; [
    lutris
    prismlauncher
    mangohud
    wineWowPackages.waylandFull
  ];

  environment.systemPackages = with pkgs; [
    dxvk
    vkd3d
  ];

  persist.user.directories = [ "games" ];
}
