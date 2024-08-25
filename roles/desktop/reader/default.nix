{ pkgs, ... }: {
  home.packages = with pkgs; [ fluent-reader ];

  persist.user.directories = [
    ".config/fluent-reader"
  ];
}
