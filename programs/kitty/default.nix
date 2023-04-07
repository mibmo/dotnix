{ config, pkgs, lib, ... }:

let
  config = ''
    set fish_greeting
    #bind \t accept-autosuggestion
  '' + themeConfig;

  plugins = with pkgs; [
    { name = "pure"; src = fishPlugins.pure.src; }
    #{ name = "tide"; src = fishPlugins.tide.src; }
    { name = "sponge"; src = fishPlugins.sponge.src; }
  ];
in
{
  programs.fish = {
    inherit plugins;

    enable = true;
    extraConfig = config;
  };
}
