{ pkgs, ... }: {
  home.settings = {
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
        gcc
        luajit
        tree-sitter
        yarn
        zig

        # plugin dependencies
        fd
        gawk
        luaPackages.jsregexp
        python310Packages.pygments
        ripgrep
        texlive.combined.scheme-full
        vscode-extensions.llvm-org.lldb-vscode

        # language servers
        lua-language-server
        lua54Packages.digestif
        nixd
        pyright
        rust-analyzer

        # debuggers
        delve

        # formatters
        black # python
        clang-tools # java
        deno # typescript
        nixpkgs-fmt # nix
        rubyPackages.htmlbeautifier # html
        stylua # lua
      ];
    };
    home.file.nvim-wgsl-queries = {
      target = ".local/share/nvim/queries/wgsl";
      source = "${pkgs.tree-sitter-grammars.tree-sitter-wgsl}/queries";
    };
  };

  persist.user.directories = [ ".local/share/nvim" ];
}
