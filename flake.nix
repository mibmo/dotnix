{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.follows = "nixpkgs-23_11";

    nixpkgs-24_05.url = "nixpkgs/nixos-24.05";
    nixpkgs-23_11.url = "nixpkgs/nixos-23.11";
    nixpkgs-23_05.url = "nixpkgs/nixos-23.05";
    nixpkgs-22_11.url = "nixpkgs/nixos-22.11";
    nixpkgs-22_05.url = "nixpkgs/nixos-22.05";
    nixpkgs-21_11.url = "nixpkgs/nixos-21.11";
    nixpkgs-21_05.url = "nixpkgs/nixos-21.05";

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
    inputs@{ conch, ... }:
    let
      lib = inputs.nixpkgs.lib // import ./lib.nix { inherit inputs; };
      config = import ./config.nix { inherit inputs lib; };
    in
    conch.load [
      "x86_64-linux"
    ]
      ({ ... }: {
        flake = {
          inherit inputs;
          nixosConfigurations = import ./hosts { inherit inputs lib config; };
        };
      });
}
