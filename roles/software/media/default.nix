{ pkgs, ... }:
{
  home.packages = with pkgs; [
    feishin
    kdePackages.kasts
    picard
  ];

  persist.user = {
    directories = [
      ".config/MusicBrainz/Picard"
      ".config/feishin"
      ".local/share/KDE/kasts"
    ];
    files = [
      ".config/KDE/kasts.conf"
      ".config/MusicBrainz/Picard.ini"
    ];
  };
}
