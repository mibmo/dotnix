{ lib, pkgs, config, settings, ... }:
let
  shellInit = ''
    set fish_greeting
  '';

  shellAbbrs = settings.shell.aliases // { };

  plugins = with pkgs.fishPlugins; [
    { name = "pure"; src = pure.src; }
    { name = "sponge"; src = sponge.src; }
    { name = "autopair"; src = autopair.src; }
    {
      name = "fuzzy_cd";
      src = pkgs.fetchFromGitHub {
        owner = "ttscoff";
        repo = "fuzzy_cd";
        rev = "0649dab1d915f322ebe477cb19e0ba7181ca07e0";
        hash = "sha256-y1dzIRH7L4B+o8Y5kLNsKGc49vmSrDYSptRaVELJEpY=";
      };
    }
  ];

  module = {
    programs.fish = {
      enable = true;
      interactiveShellInit = "any-nix-shell fish --info-right | source";
      inherit shellInit shellAbbrs plugins;
    };
  };
in
{
  environment.systemPackages = [ pkgs.any-nix-shell ];
  home-manager.users.${settings.user.name}.imports = [ module ];
  users.users.${settings.user.name}.shell = pkgs.fish;
  programs.fish.enable = true;
}
