{ pkgs, ... }: {
  home.packages = with pkgs; [
    element-desktop
    nheko
  ];

  persist.user.directories = [
    ".config/Element"
    ".config/nheko"
  ];
}
