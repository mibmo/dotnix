{ inputs, lib, config }:
let
  mkHost = host:
    lib.nixosSystem {
      inherit (host) system;
      modules = with inputs; [
        home-manager.nixosModules.home-manager
        nur.nixosModules.nur
        agenix.nixosModules.default
        hyprland.nixosModules.default
        ../roles/common.nix
        (lib.mkModule host)
      ];
      /*
      modules = with inputs; modules ++ [
        ../base.nix
        nur.nixosModules.nur
        home-manager.nixosModules.home-manager
        agenix.nixosModules.default
        hyprland.nixosModules.default
      ];
      */
    };

  hosts = lib.recurse (c: c ? name) mkHost config.hosts;
in
hosts
