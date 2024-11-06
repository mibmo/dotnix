{ settings, pkgs, ... }:

{
  imports = [
    ./fish.nix
    ./zsh.nix
  ];

  users.users.${settings.user.name}.shell = pkgs.fish;
}
