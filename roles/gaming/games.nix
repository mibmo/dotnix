{ pkgs, ... }:

{
  persist.user.directories = [
    ".factorio"
    ".local/share/PrismLauncher"
    ".local/share/Terraria"
    ".local/share/binding of isaac afterbirth+ mods"
    ".local/share/binding of isaac afterbirth+"
    ".local/share/etterna"
    ".local/share/osu"
  ];

  home.packages = with pkgs; [
    etterna
    osu-lazer-bin
    prismlauncher
  ];
}
