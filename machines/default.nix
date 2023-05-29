{ inputs, system, pkgs, settings }:
let
  lib = inputs.nixpkgs.lib;

  mkMachine = machineModule:
    lib.nixosSystem {
      inherit lib pkgs system;
      specialArgs = { inherit inputs settings; };
      modules = with inputs; [
        ../base.nix
        machineModule

        nur.nixosModules.nur
        home-manager.nixosModules.home-manager
        hyprland.nixosModules.default
      ];
    };
in
{
  hamilton = mkMachine ./hamilton;
}
