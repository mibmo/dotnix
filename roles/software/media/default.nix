{ pkgs, ... }:
{
  home.packages = with pkgs; [ feishin ];

  persist.user.directories = [ ".config/feishin" ];
}
