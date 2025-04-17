{ specification, pkgs, ... }:

{
  imports = [
    ./fish.nix
    ./zsh.nix
  ];

  users.users.${specification.user.name}.shell = pkgs.fish;
}
