{ pkgs, ... }: {
  programs.neovim = {
    enable = true;

    viAlias = false;
    vimAlias = true;
    vimdiffAlias = true;

    extraLuaConfig = builtins.readFile ./config.lua;
    extraPackages = with pkgs; [
      deno
      webkitgtk # peek.nvim dependency @TODO: deno can't see webkitgtk, so this is broken
    ];
  };
}
