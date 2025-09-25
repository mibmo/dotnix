{ pkgs, ... }:
{
  home.packages = with pkgs; [
    simplex-chat-desktop
  ];

  persist.user.directories = [
    ".local/share/simplex"
  ];
}
