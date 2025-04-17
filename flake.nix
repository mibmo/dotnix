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

    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      lib = import ./lib { inherit self inputs specification; };
      specification = import ./specification.nix { inherit inputs lib; };

      inherit (builtins) readFile;
      inherit (lib.dot) mkPkgs;
      inherit (lib.attrsets)
        attrValues
        attrsToList
        concatMapAttrs
        genAttrs
        hasAttrByPath
        isDerivation
        recursiveUpdate
        ;
      inherit (lib.lists) filter flatten fold;
      inherit (lib.strings) match splitString;

      perSystem =
        maker:
        genAttrs lib.systems.flakeExposed (
          system:
          maker rec {
            inherit inputs system lib;
            pkgs = mkPkgs system;
          }
        );

      treefmt = perSystem (
        { pkgs, ... }:
        inputs.treefmt-nix.lib.evalModule pkgs {
          projectRootFile = "flake.nix";
          settings = {
            excludes =
              let
                invalidIgnoreRuleRegex = ''(#.*|.+/)?'';
                ignoreRules = filter (rule: match invalidIgnoreRuleRegex rule == null) (
                  flatten (
                    map (rule: [
                      "**/${rule}"
                      rule
                      "${rule}/**"
                    ]) (splitString "\n" (readFile ./.gitignore))
                  )
                );
              in
              ignoreRules
              ++ [
                # unsupported
                "*.git{config,ignore}"
                "*.md"
                # binary
                "*.age"
              ];
          };
          programs.nixfmt.enable = true;
        }
      );
    in
    {
      inherit lib inputs specification;
      formatter = perSystem ({ system, ... }: treefmt.${system}.config.build.wrapper);
      nixosConfigurations = import ./hosts { inherit inputs lib specification; };
    };
}
