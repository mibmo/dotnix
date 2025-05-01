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
      url = "https://images8.alphacoders.com/137/1374980.jpg";
      hash = "sha256-y9EF4d+QeSvDqu+xR4tDKKg3XAdZzhWQhCf9GZa/zXc=";
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
