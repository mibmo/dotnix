{ pkgs, settings, ... }:

{
  imports = [
    ../internet/firefox
    ./communication
    ./fcitx5
    ./media
    ./ydotool
  ];

  environment.systemPackages = with pkgs; [
    wl-clipboard
  ];

  home = {
    settings.services = {
      easyeffects.enable = true;
      nextcloud-client = {
        enable = true;
        startInBackground = true;
      };
    };
    packages = with pkgs; [
      libreoffice
      mpv
      pulsemixer
      sioyek
      zathura
    ];
  };

  programs.dconf.enable = true;

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
        canon-cups-ufr2
        cups-bjnp
        cups-dymo
        gutenprint
      ];
    };
  };

  hardware.opentabletdriver.enable = true;

  # start nextcloud-client on user login
  systemd.user.services.nextcloud-client.wantedBy = [ "graphical.target" ];

  persist.user.directories = [ ".config/Nextcloud" ];
}
