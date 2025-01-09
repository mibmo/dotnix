{ pkgs, ... }:

{
  home.packages = with pkgs; [
    geogebra6
    tigervnc
  ];
}
