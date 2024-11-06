{ inputs, host, ... }:
{
  imports = [ ../. ];

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${host.system}.hyprland;
  };
}
