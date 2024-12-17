{ pkgs, ... }:
let
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
    nerd-fonts.fira-code

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
