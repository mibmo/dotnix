{ ... }:
let
  settings = {
    font = {
      size = 12;
      normal.family = "FantasqueSansM Nerd Font";
    };
  };
in
{
  programs.alacritty = {
    enable = true;
    inherit settings;
  };
}
