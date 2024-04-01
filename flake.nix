{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.follows = "nixpkgs-23_11";
    nixpkgs-23_11.url = "nixpkgs/nixos-23.11";

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

    disko.url = "github:nix-community/disko";
    impermanence.url = "github:nix-community/impermanence";

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
    in
    conch.load [
      "x86_64-linux"
    ]
      ({ pkgs, ... }: {
        flake.nixosConfigurations = import ./hosts { inherit inputs lib config; };
      });
}
