{ pkgs, ... }: {
  home.packages = with pkgs; [
    cinny-desktop
    element-desktop # persist broken
    fluffychat # persist broken
    nheko
  ];

  persist.user.directories = [
    ".config/Element"
    ".config/nheko"
    ".local/share/chat.fluffy.fluffychat"
    ".local/share/cinny"
    ".local/share/in.cinny.app"
  ];
}
