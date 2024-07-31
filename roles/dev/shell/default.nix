{ lib, pkgs, config, settings, ... }:
let
  terminal-theme-light = builtins.toFile "terminal-theme-light" ''
    0: #5c5f77
    1: #d20f39
    2: #40a02b
    3: #df8e1d
    4: #1e66f5
    5: #ea76cb
    6: #179299
    7: #acb0be
    8: #6c6f85
    9: #d20f39
    10: #40a02b
    11: #df8e1d
    12: #1e66f5
    13: #ea76cb
    14: #179299
    15: #bcc0cc
    foreground: #4c4f69
    background: #eff1f5
    cursor: #00/0
  '';
  terminal-theme-dark = builtins.toFile "terminal-theme-dark" ''
    0: #494d64
    1: #ed8796
    2: #a6da95
    3: #eed49f
    4: #8aadf4
    5: #f5bde6
    6: #8bd5ca
    7: #b8c0e0
    8: #5b6078
    9: #ed8796
    10: #a6da95
    11: #eed49f
    12: #8aadf4
    13: #f5bde6
    14: #8bd5ca
    15: #a5adcb
    foreground: #cad3f5
    background: #24273a
    cursor: #00/0
  '';

  shellInit = ''
    set fish_greeting

    function __light_theme
      cat ${terminal-theme-light} | INHIBIT_THEME_HIST=1 ${pkgs.theme-sh}/bin/theme.sh
    end

    function __dark_theme
      cat ${terminal-theme-dark} | INHIBIT_THEME_HIST=1 ${pkgs.theme-sh}/bin/theme.sh
    end

    __dark_theme
  '';

  shellAbbrs = settings.shell.aliases // { };

  plugins = with pkgs.fishPlugins; map
    (attrs: { inherit (attrs) name src; })
    [
      pure
      sponge
      autopair
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
in
{
  home.settings = {
    programs.fish = {
      enable = true;
      interactiveShellInit = "any-nix-shell fish --info-right | source";
      inherit shellInit shellAbbrs plugins;
    };
  };

  environment.systemPackages = [ pkgs.any-nix-shell ];
  users.users.${settings.user.name}.shell = pkgs.fish;
  programs.fish.enable = true;
  programs.nix-index.enableFishIntegration = true;

  persist.user.directories = [ ".local/share/fish" ];
}
