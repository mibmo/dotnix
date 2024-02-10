{ pkgs-23_11, settings, ... }:
let
  module = {
    programs.alacritty = {
      enable = true;
      package = pkgs-23_11.alacritty;
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
