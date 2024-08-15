{ pkgs, pkgs-24_05, ... }:
let
  kicad = pkgs-24_05.kicad.override {
    addons = with pkgs-24_05.kicadAddons; [
      kikit
      kikit-library
    ];
  };
in
{
  home.packages = with pkgs; [
    betaflight-configurator
    blender-hip
    edgetx
    freecad
    gimp
    inkscape
    kicad
    krita
    openscad-unstable
    anki
    prusa-slicer
    pkgs-24_05.renderdoc
    solvespace
  ];

  home.settings = {
    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        input-overlay
      ];
    };

    home.file.".local/share/OpenSCAD/libraries/BOSL".source =
      pkgs.fetchFromGitHub {
        owner = "revarbat";
        repo = "BOSL";
        rev = "v1.0.3";
        hash = "sha256-FHHZ5MnOWbWnLIL2+d5VJoYAto4/GshK8S0DU3Bx7O8=";
      };
  };
}
