{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.follows = "nixpkgs-unstable";
    nixpkgs-stable.follows = "nixpkgs-24_11";

    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    nixpkgs-24_11.url = "nixpkgs/nixos-24.11";
    nixpkgs-24_05.url = "nixpkgs/nixos-24.05";
    nixpkgs-23_11.url = "nixpkgs/nixos-23.11";
    #nixpkgs-23_05.url = "nixpkgs/nixos-23.05";
    #nixpkgs-22_11.url = "nixpkgs/nixos-22.11";
    #nixpkgs-22_05.url = "nixpkgs/nixos-22.05";
    #nixpkgs-21_11.url = "nixpkgs/nixos-21.11";
    #nixpkgs-21_05.url = "nixpkgs/nixos-21.05";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nur.url = "github:nix-community/NUR";

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
    stylix.url = "github:danth/stylix";
  };

  outputs =
    inputs@{ nixpkgs, ... }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib // import ./lib.nix { inherit inputs; };
      nixpkgsInstances = lib.packageSets system;
      pkgs = nixpkgsInstances.unstable;
      config = import ./config.nix { inherit inputs pkgs lib; };
    in
    {
      inherit inputs;
      formatter.${system} = pkgs.nixfmt-rfc-style;
      nixosConfigurations = import ./hosts { inherit inputs lib config; };
    };
}
