{ settings, ... }:
let
  module = {
    programs.alacritty = {
      enable = true;
      settings = {
        font = {
          size = 12;
          normal.family = "FantasqueSansM Nerd Font";
        };
      };
    };
  };
in
{
  home-manager.users.${settings.user.name}.imports = [ module ];
}
