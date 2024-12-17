{
  inputs,
  lib,
  config,
}:
let
  mkHost =
    host:
    lib.nixosSystem {
      inherit (host) system;
      modules = with inputs; [
        home-manager.nixosModules.home-manager
        disko.nixosModules.disko
        impermanence.nixosModules.impermanence
        nur.modules.nixos.default
        agenix.nixosModules.age
        hyprland.nixosModules.default
        stylix.nixosModules.stylix
        ../roles/common.nix
        (lib.mkModule host)
      ];
    };

  hosts = lib.recurse (c: c ? name) mkHost config.hosts;
in
hosts
