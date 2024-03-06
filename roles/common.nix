{ pkgs, inputs, config, settings, ... }: {
  imports = [
    ./networking
    ./home-manager
    ./security
    ./misc/fonts
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

    settings =
      let
        substituters = [
          { url = "https://nix-community.cachix.org"; key = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="; }
          { url = "https://crane.cachix.org"; key = "crane.cachix.org-1:8Scfpmn9w+hGdXH/Q9tTLiYAE/2dnJYRJP7kl80GuRk="; }
          { url = "https://deploy-rs.cachix.org"; key = "deploy-rs.cachix.org-1:xfNobmiwF/vzvK1gpfediPwpdIP0rpDV2rYqx40zdSI="; }
        ];
      in
      {
        auto-optimise-store = true;

        # avoid unwanted gc when using flakes
        keep-outputs = true;
        keep-derivations = true;

        # cachix
        substituters = map (s: s.url) substituters;
        trusted-public-keys = map (s: s.key) substituters;
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
