{ inputs, pkgs, ... }: {
  nix = {
    package = pkgs.nixVersions.unstable;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    # pin local nixpkgs to flake nixpkgs
    registry.nixpkgs.flake = inputs.nixpkgs;

    settings = {
      # enable flakes
      experimental-features = [ "nix-command" "flakes" ];

      auto-optimise-store = true;

      # avoid unwanted gc when using flakes
      keep-outputs = true;
      keep-derivations = true;
    };
  };
}
