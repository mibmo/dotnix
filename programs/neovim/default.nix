{ pkgs, ... }: {
  programs.neovim = {
    enable = true;

    viAlias = false;
    vimAlias = true;
    vimdiffAlias = true;

    extraLuaConfig = builtins.readFile ./config.lua;
    extraPackages = with pkgs.vimPlugins; [
      luasnip
      cmp_luasnip
      pkgs.deno # peek.nvim dependency
    ];
  };
}
