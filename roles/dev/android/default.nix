{ pkgs, settings, ... }: {
  home-manager.users.${settings.user.name}.home.packages = [ pkgs.android-tools ];
  users.users.${settings.user.name}.extraGroups = [ "adbusers" ];
  programs.adb.enable = true;
}
