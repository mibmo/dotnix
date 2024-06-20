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
    google
    nerd

    fantasque-sans-mono

    # japanese
    ipafont
    migmix
    migu
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    takao

    # chinese
    smiley-sans
  ];
}
