{ pkgs, ... }:

{
  home.packages = with pkgs; [ qbittorrent ];

  persist.user.directories = [ ".config/qBittorrent" ];
}
