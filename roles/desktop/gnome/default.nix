{ config, pkgs, ... }:
{
  imports = [ ../. ];

  programs.gnupg.agent.pinentryPackage = pkgs.pinentry-gnome3;

  services = {
    dbus.packages = with pkgs; [ dconf gcr ];
    udev.packages = [ pkgs.gnome3.gnome-settings-daemon ];

    xserver = {
      enable = true;

      displayManager.gdm.enable = true;
      displayManager.gdm.wayland = true;
      desktopManager.gnome.enable = true;
    };
  };

  environment.systemPackages = with pkgs.gnomeExtensions; [
    config.programs.gnupg.agent.pinentryPackage
    pkgs.file-roller

    # wayland
    kimpanel

    # top bar
    appindicator
    keep-awake
    time-awareness
    vitals

    # looks
    burn-my-windows
    material-you-color-theming
    shu-zhi
    undecorate
  ];

  # dont install default gnome applications
  environment.gnome.excludePackages = with pkgs; [
    cheese # webcam tool
    epiphany # web browser
    evince # document viewer
    geary # email readear
    gedit # text editor
    gnome-photos
    gnome-terminal
    gnome-tour
    gnome.atomix # puzzle game
    gnome.gnome-characters
    gnome.gnome-music
    gnome.hitori # sudoku game
    gnome.iagno # go game
    gnome.tali # poker game
    totem # video player
  ];

  # might need this for nvidia
  #hardware.nvidia.modesetting.enable = true;

  home.settings.xdg.configFile."shuzhi.py" = {
    executable = true;
    source = pkgs.writeScript "shuzhi.py" ''
      #!${pkgs.python3}/bin/python
      import socket

      def print_wide(*args, sep=" ", **kwargs):
        wide_map = {i: i + 0xFEE0 for i in range(0x21, 0x7F)}
        wide_map[0x20] = 0x3000
        text = sep.join(map(str, args)).translate(wide_map)
        print(text, **kwargs)

      print("こんにちは")
      print_wide(socket.gethostname())
    '';
  };
}
