{ pkgs, ... }:
let
  nerd = pkgs.nerdfonts.override {
    fonts = [
      "FiraCode"
    ];
  };
  google = pkgs.google-fonts.override {
    fonts = [
      "Nunito"
      "Roboto"
    ];
  };
in
{
  fonts.packages = with pkgs; [
    nerd
    google

    fantasque-sans-mono

    # japanese
    noto-fonts-cjk-serif
    noto-fonts-cjk-sans
    migmix
    migu
    ipafont
    takao

    # chinese
    smiley-sans
  ];
}
