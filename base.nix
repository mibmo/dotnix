{ config, pkgs, home-manager, ... }:
let
  user = {
    name = "mib";
    home = "/home/${user.name}"; # @TODO: support darwin
    email = "mib@kanp.ai";
    gpgKeyId = null;
  };
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
  imports = [ (import ./programs user) ];

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
    # disable the global DHCP flag as it is deprecated
    useDHCP = false;

    firewall.enable = false;

    networkmanager.enable = true;
  };
  services.dnsmasq = {
    enable = true;

    settings = {
      no-resolv = true;
      dnssec = true;
      conf-file = "${pkgs.dnsmasq}/share/dnsmasq/trust-anchors.conf";
      cache-size = "1000";
      server = [
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
    printing.enable = true;
    udev.extraRules = udevRules;

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
    };
    systemPackages = with pkgs; [
      opentabletdriver
    ];
  };

  programs.fish.enable = true;
  users.users.${user.name} = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [ "wheel" "input" "networkmanager" ];
  };

  # read the docs (or crash and burn)
  system.stateVersion = "22.11";
}
