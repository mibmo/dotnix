{ pkgs, ... }:

{
  stylix = {
    enable = true;
    image = pkgs.fetchurl {
      url = "https://images2.alphacoders.com/137/1379605.png";
      hash = "sha256-VOO3j8EGXb33qJkJA8pi2jF/RkiqMHUrO19dDiH+hyk=";
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
    };
    targets = {
      # manage myself
      plymouth.enable = false;
    };
  };
}
