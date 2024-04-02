{ pkgs-23_11, ... }: {
  home.settings = {
    programs = {
      alacritty = {
        enable = true;
        package = pkgs-23_11.alacritty;
        settings = {
          font = {
            size = 12;
            normal.family = "Fantasque Sans Mono";
          };
        };
      };
      foot = {
        enable = true;
        settings = {
          main = {
            font = "Fantasque Sans Mono";
            font-size-adjustment = 0.5;
            pad = "10x10 center";
            dpi-aware = true;
          };
          text-bindings = {
            # patch for broken d-key in neovim
            "d" = "Mod4+d";
            "D" = "Mod4+D";
          };
          csd.size = 0;
        };
      };
    };
  };
}
