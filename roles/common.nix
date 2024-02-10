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

    settings = {
      auto-optimise-store = true;

      # avoid unwanted gc when using nix-direnv
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
