{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nur.url = "github:nix-community/NUR";

    conch = {
      url = "github:mibmo/conch";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        darwin.follows = "";
      };
    };

    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs =
    inputs@{ nixpkgs, conch, ... }:
    let
      lib = inputs.nixpkgs.lib // import ./lib.nix { inherit inputs; };
      config = import ./config.nix { inherit inputs lib; };

      /*
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = builtins.map (path: import path) [
          ./overlays/gnome-shell.nix
        ];
      };
      */
    in
    conch.load [
      "x86_64-linux"
    ]
      ({ pkgs, ... }: {
        flake.nixosConfigurations = import ./hosts { inherit inputs lib config; };
      });
}
