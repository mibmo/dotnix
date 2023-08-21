{ settings, lib, config, pkgs, home-manager, ... }:
let
  nerdFonts = pkgs.nerdfonts.override {
    fonts = [
      "FiraCode"
      "FantasqueSansMono"
    ];
  };
  googleFonts = pkgs.google-fonts.override {
    fonts = [ "Nunito" ];
  };
  udevRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0664", GROUP="plugdev"
  '';
in
{
  imports = [ (import ./programs settings) ];

  nix = {
    package = pkgs.nixVersions.unstable;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    extraOptions = "experimental-features = nix-command flakes";

    settings = {
      auto-optimise-store = true;

      # avoid unwanted gc when using nix-direnv
      keep-outputs = true;
      keep-derivations = true;
    };
  };

  networking = {
    firewall.enable = false;

    networkmanager = {
      enable = true;
      insertNameservers = [
        "9.9.9.9"
        "149.112.112.112"
        "2620:fe::fe"
        "2620:fe::9"
      ];
    };
  };

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    wireplumber.enable = true;

    alsa.enable = true;
    jack.enable = true;
    pulse.enable = true;
  };

  # locale-dependent
  i18n.defaultLocale = "en_DK.UTF-8";
  console.keyMap = "dk";

  # time
  time.timeZone = "Europe/Copenhagen";
  services.ntp.enable = true;

  services = {
    printing = {
      enable = true;
      drivers = with pkgs; [
        gutenprint
        cups-bjnp
        carps-cups
        canon-cups-ufr2
      ];
    };
    udev.extraRules = udevRules;
    pcscd.enable = true;

    # @TODO: enable local monitoring with prometheus & grafana
  };

  fonts.fonts = with pkgs; [
    nerdFonts
    googleFonts

    # japanese fonts
    noto-fonts-cjk-serif
    noto-fonts-cjk-sans
    migmix
    migu
    ipafont
    takao
  ];

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
      fcitx5-lua
      fcitx5-mozc
    ];
  };

  environment = {
    variables = {
      # fcitx5
      GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
      YDOTOOL_SOCKET = "/run/ydotool.socket";
    };
    systemPackages = with pkgs; [
      opentabletdriver
    ];
  };

  # gpg
  hardware.gpgSmartcards.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.fish.enable = true;
  users.users.${settings.user.name} = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [ "wheel" "input" "networkmanager" ];
    passwordFile = config.age.secrets.user_password.path;
  };
  systemd.services.ydotoold = {
    description = "An auto-input utility for wayland";
    documentation = [ "man:ydotool(1)" "man:ydotoold(8)" ];
    wantedBy = ["multi-user.target"];
    
    serviceConfig.ExecStart = ''
      ${pkgs.ydotool}/bin/ydotoold \
        --socket-path=${config.environment.variables.YDOTOOL_SOCKET} \
        --socket-own=0:1 \
        --socket-perm=0660
    '';
  };

  age = {
    identityPaths = [ (config.users.users.${settings.user.name}.home + "/.secret/age.keys") ];
    secrets =
      let
        config = import ./secrets/secrets.nix;
        secrets = builtins.mapAttrs (name: value: { file = ./secrets/${name}; }) config;
      in
      secrets;
  };

  # read the docs (or crash and burn)
  system.stateVersion = "22.11";
}
