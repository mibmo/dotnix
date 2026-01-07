{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [ android-tools ];
    groups = [ "adbusers" ];
  };
}
