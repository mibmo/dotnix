{ pkgs, ... }: {
  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      extraPkgs = pkgs: with pkgs; [ mangohud gamescope gamemode ];
    };
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
}
