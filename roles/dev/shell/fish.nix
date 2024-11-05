{ lib, pkgs, config, settings, ... }:
let
  shellInit =
    let
      # fzf and fish break together, so can't just have this in shell variable... :/
      fdOpts = "--type=directory --full-path --exclude nixpkgs";
    in
    ''
      set fish_greeting

      function __is_project_dir
        set  $status
      end

      function dev -d "Find directory in dev folder based on search and cd into it"
        cd $(fzf \
          --bind 'start:reload:fd "" ~/dev ${fdOpts}' \
          --bind 'change:reload:fd {q} ~/dev ${fdOpts} || true' \
          --preview='tree -CL 2 {}' \
          --height=50% --layout=reverse \
          --query "$argv")
      end
    '';

  shellAbbrs = settings.shell.aliases // { };

  plugins = with pkgs.fishPlugins; map
    (attrs: { inherit (attrs) name src; })
    [
      pure
      sponge
      autopair
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
