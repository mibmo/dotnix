{
  pkgs,
  pkgs-24_05,
  ...
}:
{
  home.packages = with pkgs; [
    pkgs-24_05.electrum-ltc
    monero-gui
  ];

  persist.user.directories = [
    ".config/monero-project"
    ".electrum-ltc"
    "assets/wallets"
  ];
}
