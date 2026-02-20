{ pkgs, pkgs-stable, ... }:
{
  home.settings = {
    programs.neovim = {
      enable = true;

      package = pkgs-stable.neovim-unwrapped;

      viAlias = false;
      vimAlias = true;
      vimdiffAlias = true;

      extraLuaConfig = builtins.readFile ./config.lua;

      withNodeJs = true;
      withPython3 = true;
      withRuby = true;

      extraPackages = with pkgs-stable; [
        sioyek

        # build tools
        gcc
        luajit
        tree-sitter
        yarn
        zig

        # plugin dependencies
        fd
        gawk
        luaPackages.jsregexp
        python313Packages.pygments
        ripgrep
        texlive.combined.scheme-full
        vscode-extensions.llvm-org.lldb-vscode

        # language servers
        lua-language-server
        lua54Packages.digestif
        nixd
        pyright
        pkgs.rust-analyzer
        kdePackages.qtdeclarative # qml
        clang-tools # c & cpp

        # debuggers
        delve

        # formatters
        black # python
        google-java-format # java
        deno # typescript
        nixfmt-rfc-style # nix
        prettier # css & html
        stylua # lua
      ];
    };
    home.file.nvim-wgsl-queries = {
      target = ".local/share/nvim/queries/wgsl";
      source = "${pkgs-stable.tree-sitter-grammars.tree-sitter-wgsl}/queries";
    };
    stylix.targets.neovim.plugin = "base16-nvim";
  };

  persist.user.directories = [ ".local/share/nvim" ];
}
