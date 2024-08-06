{ pkgs-23_11, ... }: {
  home = {
    packages = [ pkgs-23_11.android-tools ];
    groups = [ "adbusers" ];
  };
  programs.adb.enable = true;
}
