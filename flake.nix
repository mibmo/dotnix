{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs @ { self, nixpkgs, nur, home-manager, ... }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations = import ./machines { inherit inputs system nur home-manager; };

      formatter.${system} = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;

      /*
      devShell.${system} = (
        import ./shell.nix {
          inherit system nixpkgs;
        }
      );
      */
    };
}
