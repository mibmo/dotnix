{ pkgs, ... }:
{
  home.packages = with pkgs; [
    feishin
    picard
  ];

  persist.user = {
    directories = [
      ".config/MusicBrainz/Picard"
      ".config/feishin"
    ];
    files = [
      ".config/MusicBrainz/Picard.ini"
    ];
  };
}
