{ pkgs, ... }:

{
  home.packages = with pkgs; [
    geogebra6
    joplin-desktop
    tigervnc
  ];
}
