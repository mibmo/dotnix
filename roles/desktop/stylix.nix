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
    image = pkgs.fetchurl {
      url = "https://images3.alphacoders.com/608/thumb-1920-608170.jpg";
      hash = "sha256-OilFco6QdTinL7nehKjnHxDkhKswPQy0Vx8pIWRRREs=";
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
