{ pkgs, settings, ... }:

{
  imports = [
    ../internet/firefox
    ./stylix.nix
    ./communication
    ./fcitx5
    ./media
    ./notes
    ./reader
    ./ydotool
  ];

  environment.systemPackages = with pkgs; [
    wl-clipboard
  ];

  home = {
    settings = {
      services.easyeffects.enable = true;
      programs = {
        imv.enable = true;
        mpv.enable = true;
        sioyek = {
          enable = true;
          config."should_launch_new_window" = "1";
        };
        zathura.enable = true;
      };
    };
    packages = with pkgs; [
      drawio
      libreoffice
      pulsemixer
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
        hplip
      ];
    };
  };

  hardware.opentabletdriver.enable = true;

  persist.user.directories = [
    ".local/share/keyrings"
  ];
}
