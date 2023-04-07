{ config, pkgs, lib, ... }:

let
  themeConfig = '''';

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
    interactiveShellInit = "any-nix-shell fish --info-right | source";
    shellInit = config;
    shellAbbrs = {
      e = "nvim";
      ns = "nix-shell";
    };
  };
}
