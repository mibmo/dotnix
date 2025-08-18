{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    electrum-ltc
    monero-gui
  ];

  persist.user.directories = [
    ".config/monero-project"
    ".electrum-ltc"
    ".local/share/Haveno-reto"
    "assets/wallets"
  ];
}
