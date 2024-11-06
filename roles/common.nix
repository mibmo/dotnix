{
  lib,
  pkgs,
  inputs,
  config,
  settings,
  ...
}:
{
  imports = [
    ./networking
    ./security
    ./misc/fonts
  ];

  substituters = [
    "cache.ngi0.nixos.org-1:KqH5CBLNSyX184S9BKZJo1LxrxJ9ltnY2uAs5c/f1MA="
    "conduit.cachix.org-1:eoSbRnf/MRgV54rQ9rFdrnB3FH25KN9IYjgfT4FY0YQ="
    "crane.cachix.org-1:8Scfpmn9w+hGdXH/Q9tTLiYAE/2dnJYRJP7kl80GuRk="
    "deploy-rs.cachix.org-1:xfNobmiwF/vzvK1gpfediPwpdIP0rpDV2rYqx40zdSI="
    "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];

  # locale
  i18n.defaultLocale = "en_DK.UTF-8";
  console.keyMap = "dk";

  # time
  time.timeZone = "Europe/Copenhagen";
  services.ntp.enable = true;

  users = {
    mutableUsers = false;
    users.${settings.user.name} = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "input"
        "systemd-journal"
      ];
      hashedPasswordFile = config.age.secrets.user_password.path;
    };
  };
}
