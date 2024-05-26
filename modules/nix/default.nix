{ inputs, pkgs, ... }: {
  nix = {
    package = pkgs.nixVersions.git;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    optimise = {
      automatic = true;
      dates = [ "hourly" ];
    };

    # pin local nixpkgs to flake nixpkgs
    registry.nixpkgs.flake = inputs.nixpkgs;

    settings =
      let
        KiB = 1024;
        MiB = 1024 * KiB;
        GiB = 1024 * MiB;
      in
      {
        # enable flakes
        experimental-features = [ "nix-command" "flakes" ];

        # gc
        min-free = 1 * GiB;
        max-free = 5 * GiB;

        # avoid unwanted gc when using flakes
        keep-outputs = true;
        keep-derivations = true;
      };
  };
}
