{ inputs, system, nur, home-manager, ... }:
let
  lib = inputs.nixpkgs.lib;

  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
    config.packageOverrides = {pkgs, ...}: { nur = import inputs.nur { inherit pkgs; }; };
  };

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
