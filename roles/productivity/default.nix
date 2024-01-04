{ pkgs, settings, ... }: {
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
