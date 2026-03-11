{ pkgs, ... }:
{
  home.packages = with pkgs; [
    feishin
    kdePackages.kasts
    nicotine-plus
    picard
  ];

  persist.user = {
    directories = [
      ".config/MusicBrainz"
      ".config/feishin"
      ".config/nicotine"
      ".local/share/KDE/kasts"
      ".local/share/nicotine"
    ];
    files = [
      ".config/KDE/kasts.conf"
    ];
  };
}
