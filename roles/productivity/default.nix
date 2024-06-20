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
    openscad-unstable
  ];

  home.settings.home.file.".local/share/OpenSCAD/libraries/BOSL".source =
    pkgs.fetchFromGitHub {
      owner = "revarbat";
      repo = "BOSL";
      rev = "v1.0.3";
      hash = "sha256-FHHZ5MnOWbWnLIL2+d5VJoYAto4/GshK8S0DU3Bx7O8=";
    };
}
