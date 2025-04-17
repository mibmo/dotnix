{
  lib,
  pkgs,
  specification,
  ...
}:
let
  inherit (lib.dot) setIf;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.strings) concatStringsSep;

  shellCommands = mapAttrsToList (name: body: ''
    function ${name}() {
      ${body}
    }
  '') specification.shell.functions;

  initExtra = ''
    # config functions
    ${concatStringsSep "\n" shellCommands}
  '';

  shellAliases = specification.shell.aliases // { };

  usePlugin =
    attrs@{
      name ? plugin.name,
      plugin,
      file ? null,
    }:
    {
      inherit name;
      inherit (plugin) src;
      ${setIf "file" (file != null)} = file;
    };
  plugins = map usePlugin [
    {
      name = "F-Sy-H";
      plugin = pkgs.zsh-f-sy-h;
    }
    {
      name = "autopair";
      plugin = pkgs.zsh-autopair;
    }
    {
      name = "jq";
      plugin = pkgs.jq-zsh-plugin;
    }
    {
      name = "nix-shell";
      plugin = pkgs.zsh-nix-shell;
    }
    {
      name = "pure";
      plugin = pkgs.pure-prompt;
    }
    {
      name = "zsh-history-substring-search";
      plugin = pkgs.zsh-history-substring-search;
    }
  ];
in
{
  home.settings = {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      enableVteIntegration = true;
      inherit initExtra shellAliases plugins;
      antidote.enable = true;
    };
  };

  programs.zsh.enable = true;

  persist.user.files = [ ".zsh_history" ];
}
