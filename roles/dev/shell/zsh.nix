{ lib, clib, pkgs, config, settings, ... }:
let
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.strings) concatStringsSep;

  shellCommands =
    mapAttrsToList
      (name: body: ''
        function ${name}() {
          ${body}
        }
      '')
      settings.shell.functions;

  initExtra = ''
    # config functions
    ${concatStringsSep "\n" shellCommands}
  '';

  shellAliases = settings.shell.aliases // { };

  usePlugin =
    attrs@{ name ? plugin.name, plugin, file ? null }: {
      inherit name;
      inherit (plugin) src;
      ${clib.setIf "file" (file != null)} = file;
    };
  plugins = map usePlugin [
    { name = "F-Sy-H"; plugin = pkgs.zsh-f-sy-h; }
    { name = "autopair"; plugin = pkgs.zsh-autopair; }
    { name = "jq"; plugin = pkgs.jq-zsh-plugin; }
    { name = "nix-shell"; plugin = pkgs.zsh-nix-shell; }
    { name = "pure"; plugin = pkgs.pure-prompt; }
    { name = "zsh-history-substring-search"; plugin = pkgs.zsh-history-substring-search; }
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

  # these are mutually exclusive
  programs.nix-index.enableZshIntegration = true;
  programs.command-not-found.enable = false;

  persist.user.files = [ ".zsh_history" ];
}
