{ ... }:
let
  settings = {
    font = {
      size = 12;
      normal.family = "FantasqueSansMono Nerd Font";
    };
  };
in
{
  programs.alacritty = {
    enable = true;
    inherit settings;
  };
}
