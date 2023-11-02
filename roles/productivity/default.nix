{ pkgs, settings, ... }: {
  home-manager.users.${settings.user.name}.home.packages = with pkgs; [
    blender
    #freecad # broken on unstable as of 2023-11-02 due to pyside2 not supporting python > 3.10
    kicad
    solvespace
    inkscape
    gimp
    prusa-slicer
    betaflight-configurator
    edgetx
  ];
}
