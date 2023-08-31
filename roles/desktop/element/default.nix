{ pkgs, config, settings, ... }:
{
  home-manager.users.${settings.user.name}.home.packages = [
    pkgs.element-desktop
  ];
}
