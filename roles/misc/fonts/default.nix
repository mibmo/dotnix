{ pkgs, ... }:
let
  nerd = pkgs.nerdfonts.override {
    fonts = [
      "FiraCode"
      "FantasqueSansMono"
    ];
  };
  google = pkgs.google-fonts.override {
    fonts = [ "Nunito" ];
  };
in
{
  fonts.packages = with pkgs; [
    nerd
    google

    # japanese fonts
    noto-fonts-cjk-serif
    noto-fonts-cjk-sans
    migmix
    migu
    ipafont
    takao
  ];
}
