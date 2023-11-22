{ pkgs, settings, ... }:
let
  module = {
    programs.neovim = {
      enable = true;

      viAlias = false;
      vimAlias = true;
      vimdiffAlias = true;

      extraLuaConfig = builtins.readFile ./config.lua;

      withNodeJs = true;
      withPython3 = true;
      withRuby = true;

      extraPackages = with pkgs; [
        zathura

        # build tools
        yarn
        gcc

        # plugin dependencies
        luaPackages.jsregexp
        vscode-extensions.llvm-org.lldb-vscode
        texlive.combined.scheme-full
        python310Packages.pygments
        ripgrep
        fd

        # language servers
        lua-language-server
        nixd
        rust-analyzer
        pyright
        lua54Packages.digestif

        # debuggers
        delve

        # formatters
        stylua # lua
        nixpkgs-fmt # nix
        black # python
        deno # typescript
        clang-tools # java
      ];
    };
  };
in
{
  home-manager.users.${settings.user.name} = {
    imports = [ module ];
    home.sessionVariables.EDITOR = "nvim";
  };
  environment.variables.EDITOR = "nvim";
}
