{ pkgs, settings, ... }: {
  home-manager.users.${settings.user.name}.home.packages = with pkgs; [
    blender
    freecad
    solvespace
    inkscape
    gimp
    prusa-slicer
  ];
}
