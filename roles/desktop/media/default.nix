{ pkgs, ... }:

{
  home.packages = with pkgs; [ qbittorrent ];

  persist.user = {
    files = [
      ".config/qBittorrent/qBittorrent-data.conf" # stats
    ];
    directories = [ ".local/share/qBittorrent" ];
  };
}
