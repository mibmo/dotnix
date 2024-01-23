{ pkgs, settings, ... }:
let
  kicad = pkgs.kicad-unstable.override {
    addons = with pkgs.kicadAddons; [
      kikit
      kikit-library
    ];
  };
in
{
  home-manager.users.${settings.user.name}.home.packages = with pkgs; [
    blender-hip
    freecad
    kicad
    solvespace
    inkscape
    gimp
    prusa-slicer
    betaflight-configurator
    edgetx
  ];
}
