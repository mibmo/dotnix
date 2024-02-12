{ pkgs-23_11, settings, ... }:
let
  module = {
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
            #pad = "10x10 center";
            dpi-aware = true;
          };
          text-bindings."\\x03" = "Mod4+c";
          csd.size = 0;
        };
      };
    };
  };
in
{
  home-manager.users.${settings.user.name}.imports = [ module ];
}
