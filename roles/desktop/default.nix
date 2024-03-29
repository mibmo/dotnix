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
    ./fcitx5
    ./ydotool
    ./element
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
  services.pipewire = {
    enable = true;
    wireplumber.enable = true;

    alsa.enable = true;
    jack.enable = true;
    pulse.enable = true;
  };

  hardware.opentabletdriver.enable = true;

  # start nextcloud-client on user login
  systemd.user.services.nextcloud-client.wantedBy = [ "default.target" ];
}
