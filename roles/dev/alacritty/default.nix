{ settings, ... }:
let
  module = {
    programs.alacritty = {
      enable = true;
      settings = {
        font = {
          size = 12;
          normal.family = "Fantasque Sans Mono";
        };
      };
    };
  };
in
{
  home-manager.users.${settings.user.name}.imports = [ module ];
}
