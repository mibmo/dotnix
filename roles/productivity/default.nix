{ pkgs, pkgs-stable, ... }:
let
  kicad = pkgs-stable.kicad.override {
    addons = with pkgs-stable.kicadAddons; [
      kikit
      kikit-library
    ];
  };

  inkscape = pkgs.inkscape-with-extensions.override {
    inkscapeExtensions = with pkgs.inkscape-extensions; [
      textext # latex and typst support
    ];
  };
in
{
  home.packages = with pkgs; [
    audacity
    betaflight-configurator
    pkgs-stable.blender-hip
    edgetx
    freecad
    gimp3
    godot_4
    inkscape
    kicad
    krita
    musescore
    pkgs-stable.openscad-unstable
    anki
    penpot-desktop
    prusa-slicer
    pkgs-stable.renderdoc
  ];

  home.settings = {
    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        input-overlay
      ];
    };

    home.file.".local/share/OpenSCAD/libraries/BOSL".source = pkgs.fetchFromGitHub {
      owner = "revarbat";
      repo = "BOSL";
      rev = "v1.0.3";
      hash = "sha256-FHHZ5MnOWbWnLIL2+d5VJoYAto4/GshK8S0DU3Bx7O8=";
    };
  };

  persist.user.directories = [
    ".config/obs-studio"
    ".local/share/Anki2"
  ];
}
