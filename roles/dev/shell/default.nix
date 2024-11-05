{ settings, pkgs, ... }:

{
  imports = [
    ./fish.nix
  ];

  users.users.${settings.user.name}.shell = pkgs.fish;
}
