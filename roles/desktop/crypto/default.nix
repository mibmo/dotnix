{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    # @TODO: add back. currently depends on vulnerable ecdsa
    #electrum-ltc
    monero-cli
    monero-gui
  ];

  persist.user.directories = [
    ".config/monero-project"
    ".electrum-ltc"
    ".local/share/Haveno-reto"
    "assets/wallets"
  ];
}
