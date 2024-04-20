{ pkgs, ... }: {
  home.packages = with pkgs; [
    cinny-desktop
    element-desktop
    fluffychat
    nheko
  ];

  persist.user.directories = [
    ".config/Element"
    ".config/nheko"
    ".local/share/chat.fluffy.fluffychat"
    ".local/share/cinny"
  ];
}
