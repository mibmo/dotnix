{ pkgs, pkgs-23_11, ... }:
let
  kicad = pkgs.kicad.override {
    addons = with pkgs.kicadAddons; [
      kikit
      kikit-library
    ];
  };
in
{
  home.packages = with pkgs; [
    pkgs-23_11.anki
    blender-hip
    freecad
    kicad
    solvespace
    inkscape
    gimp
    krita
    prusa-slicer
    renderdoc
    betaflight-configurator
    edgetx
  ];
}
