{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs =
    inputs @ { self, nixpkgs, nur, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = builtins.map (path: import path) [
          ./overlays/gnome-shell.nix
        ];
      };
      settings = import ./settings.nix;
    in
    {
      nixosConfigurations = import ./machines { inherit inputs system pkgs settings; };

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
