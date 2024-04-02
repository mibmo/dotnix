{ pkgs, ... }: {
  home = {
    packages = [ pkgs.android-tools ];
    groups = [ "adbusers" ];
  };
  programs.adb.enable = true;
}
