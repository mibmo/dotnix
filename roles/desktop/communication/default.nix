{ pkgs, ... }: {
  home.packages = with pkgs; [
    cinny-desktop
    element-desktop
    nheko
  ];

  persist.user.directories = [
    ".config/Element"
    ".config/nheko"
    ".local/share/cinny"
  ];
}
