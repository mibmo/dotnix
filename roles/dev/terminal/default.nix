{ lib, ... }:
{
  home.settings = {
    programs = {
      alacritty.enable = true;
      foot = {
        enable = true;
        settings = lib.mkForce {
          main = {
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
