{
  inputs,
  pkgs,
  specification,
  ...
}:
{
  imports = [
    ./distributed-builds.nix
  ];

  substituters = [
    #"cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    #"cache.ngi0.nixos.org-1:KqH5CBLNSyX184S9BKZJo1LxrxJ9ltnY2uAs5c/f1MA="
    #"conduit.cachix.org-1:eoSbRnf/MRgV54rQ9rFdrnB3FH25KN9IYjgfT4FY0YQ="
    "crane.cachix.org-1:8Scfpmn9w+hGdXH/Q9tTLiYAE/2dnJYRJP7kl80GuRk="
    "deploy-rs.cachix.org-1:xfNobmiwF/vzvK1gpfediPwpdIP0rpDV2rYqx40zdSI="
    #"devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    #"hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];

  nix = {
    registry.dotnix = {
      exact = true;
      from = {
        type = "indirect";
        id = "dotnix";
      };
      to = {
        type = "path";
        path = "/home/${specification.user.name}/${specification.path-to-flake}";
      };
    };

    #package = pkgs.nixVersions.stable;

    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 30d";
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
        experimental-features = [
          "nix-command"
          "flakes"
          "ca-derivations"
        ];

        # gc
        min-free = 1 * GiB;

        # avoid unwanted gc when using flakes
        keep-outputs = true;
        keep-derivations = true;
      };
  };
}
