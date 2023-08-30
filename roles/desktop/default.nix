{ pkgs, settings, ... }: {
  imports = [
    ../internet/firefox
    ./ydotool
    ./element
  ];

  environment.systemPackages = with pkgs; [
    wl-clipboard
  ];

  home-manager.users.${settings.user.name}.home.packages = with pkgs; [
    mpv
    zathura
    libreoffice
    easyeffects
  ];

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    wireplumber.enable = true;

    alsa.enable = true;
    jack.enable = true;
    pulse.enable = true;
  };
}
