{ inputs, system, pkgs, nur, home-manager }:
let
  lib = inputs.nixpkgs.lib;

  mkMachine = machineModule:
    lib.nixosSystem {
      inherit lib pkgs system;
      specialArgs = { inherit inputs; };
      modules = [
        ../base.nix
        nur.nixosModules.nur
        home-manager.nixosModules.home-manager
        machineModule
      ];
    };
in
{
  hamilton = mkMachine ./hamilton;
}
