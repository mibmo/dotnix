{ pkgs, settings, ... }:
let
  module = {
    services = {
      easyeffects.enable = true;
      nextcloud-client = {
        enable = true;
        startInBackground = true;
      };
    };
  };
in
{
  imports = [
    ../internet/firefox
    ./communication
    ./fcitx5
    ./ydotool
  ];

  environment.systemPackages = with pkgs; [
    wl-clipboard
  ];

  home-manager.users.${settings.user.name} = {
    imports = [ module ];
    home.packages = with pkgs; [
      mpv
      zathura
      libreoffice
      pulsemixer
      qbittorrent
    ];
  };

  programs.dconf.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  services = {
    pipewire = {
      enable = true;
      wireplumber.enable = true;

      alsa.enable = true;
      jack.enable = true;
      pulse.enable = true;
    };
    xserver.xkb.layout = "dk";
    libinput = {
      enable = true;
      touchpad.disableWhileTyping = true;
    };
    printing = {
      enable = true;
      stateless = true;
      startWhenNeeded = true;
      drivers = with pkgs; [
        brlaser
        cups-bjnp
        cups-dymo
        gutenprint
      ];
    };
  };

  hardware.opentabletdriver.enable = true;

  # start nextcloud-client on user login
  systemd.user.services.nextcloud-client.wantedBy = [ "default.target" ];
}
