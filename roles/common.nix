{ lib, pkgs, inputs, config, settings, ... }: {
  imports = [
    ./networking
    ./home-manager
    ./security
    ./misc/fonts
  ];

  substituters = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "crane.cachix.org-1:8Scfpmn9w+hGdXH/Q9tTLiYAE/2dnJYRJP7kl80GuRk="
    "deploy-rs.cachix.org-1:xfNobmiwF/vzvK1gpfediPwpdIP0rpDV2rYqx40zdSI="
    "conduit.cachix.org-1:eoSbRnf/MRgV54rQ9rFdrnB3FH25KN9IYjgfT4FY0YQ="
  ];

  nix = {
    package = pkgs.nixVersions.unstable;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    extraOptions = "experimental-features = nix-command flakes";

    # pin local nixpkgs to flake nixpkgs
    registry.nixpkgs.flake = inputs.nixpkgs;

    settings = {
      auto-optimise-store = true;

      # avoid unwanted gc when using flakes
      keep-outputs = true;
      keep-derivations = true;
    };
  };

  # locale
  i18n.defaultLocale = "en_DK.UTF-8";
  console.keyMap = "dk";

  # time
  time.timeZone = "Europe/Copenhagen";
  services.ntp.enable = true;

  users.users.${settings.user.name} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "input" ];
    passwordFile = config.age.secrets.user_password.path;
  };
}
