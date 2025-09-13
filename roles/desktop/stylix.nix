{ pkgs, ... }:

{
  stylix = {
    enable = true;
    # nice wallpapers:
    # - https://wall.alphacoders.com/big.php?i=1379605
    # - https://wall.alphacoders.com/big.php?i=1374980
    # - https://wall.alphacoders.com/big.php?i=595859
    # - https://wall.alphacoders.com/big.php?i=1316373
    # - https://wall.alphacoders.com/big.php?i=787153
    # - https://wall.alphacoders.com/big.php?i=608170
    # - https://wall.alphacoders.com/big.php?i=1317591
    # - https://wall.alphacoders.com/big.php?i=1185563
    # - https://wall.alphacoders.com/big.php?i=1378883
    # - https://wall.alphacoders.com/big.php?i=1330681
    # - https://wall.alphacoders.com/big.php?i=700301
    # - https://wall.alphacoders.com/big.php?i=1053832
    # - https://wall.alphacoders.com/big.php?i=1313211
    # - https://wall.alphacoders.com/big.php?i=1314602
    # - https://wall.alphacoders.com/big.php?i=1315430
    # - https://wall.alphacoders.com/big.php?i=1314599
    # - https://wall.alphacoders.com/big.php?i=782164
    # - https://wall.alphacoders.com/big.php?i=1140173
    # - https://wall.alphacoders.com/big.php?i=1271728
    # - https://wall.alphacoders.com/big.php?i=1305211
    # - https://wall.alphacoders.com/big.php?i=1282153
    # - https://wall.alphacoders.com/big.php?i=104722
    # - https://wall.alphacoders.com/big.php?i=1144040
    # - https://www.wallpaperhub.app/wallpapers/12229
    image = pkgs.fetchurl {
      url = "https://images2.alphacoders.com/130/1305211.png";
      hash = "sha256-L+pDNTpz/cfyI7ADYYhsHq/v9FrZ3po5Vz672tF0acU=";
    };
    fonts = {
      monospace = {
        name = "Fantasque Sans Mono";
        package = pkgs.fantasque-sans-mono;
      };
      sizes = {
        applications = 12;
        desktop = 12;
        terminal = 12;
      };
    };
    cursor = {
      name = "BreezeX-RosePine-Linux";
      package = pkgs.rose-pine-cursor;
      size = 32;
    };
    targets = {
      # manage myself
      plymouth.enable = false;
    };
  };
}
