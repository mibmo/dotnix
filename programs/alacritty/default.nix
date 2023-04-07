{ ... }:
let
  settings = {
    font = {
      size = 12;
      normal.family = "monospace";
    };
  };
in
{
  programs.alacritty = {
    enable = true;
    inherit settings; 
  };
}
