{ inputs, system, pkgs, settings }:
let
  lib = inputs.nixpkgs.lib;

  mkMachine = modules:
    lib.nixosSystem {
      inherit lib pkgs system;
      specialArgs = { inherit inputs settings system; };
      modules = with inputs; modules ++ [
        ../base.nix
        nur.nixosModules.nur
        home-manager.nixosModules.home-manager
        agenix.nixosModules.default
        hyprland.nixosModules.default
      ];
    };
in
with inputs.nixos-hardware.nixosModules; {
  hamilton = mkMachine [ ./hamilton asus-zephyrus-ga503 ];
}
