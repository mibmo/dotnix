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
      deno
      webkitgtk # peek @TODO: deno can't see webkitgtk, so this is broken

      texlive.combined.scheme-full # tex distribution
      python310Packages.pygments # tex minted
    ];
  };
}
