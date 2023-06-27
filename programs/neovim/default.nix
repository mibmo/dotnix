{ pkgs, ... }: {
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

      # debuggers
      delve
    ];
  };
}
