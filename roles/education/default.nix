{ pkgs, settings, ... }:
{

  home-manager.users.${settings.user.name}.home.packages = with pkgs; [
    geogebra6
    joplin-desktop
  ];
}
