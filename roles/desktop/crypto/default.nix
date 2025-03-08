{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    monero-gui
  ];

  persist.user.directories = [
    ".config/monero-project"
    "assets/wallets"
  ];
}
