{ pkgs, ... }:
{
  programs.gnupg.agent.pinentryFlavor = "gnome3";

  services = {
    dbus.packages = with pkgs; [ dconf gcr ];
    udev.packages = [ pkgs.gnome3.gnome-settings-daemon ];

    xserver = {
      enable = true;
      layout = "dk";

      # enable touchpad support
      libinput.enable = true;

      displayManager.gdm.enable = true;
      displayManager.gdm.wayland = true;
      desktopManager.gnome.enable = true;
    };
  };

  environment.systemPackages = with pkgs.gnomeExtensions; [
    pkgs.pinentry-gnome
    pkgs.gnome.file-roller

    # wayland
    kimpanel

    # top bar
    appindicator
    keep-awake
    time-awareness
    vitals

    # looks
    burn-my-windows
    undecorate
    shu-zhi
    material-you-color-theming
  ];

  # dont install default gnome applications
  environment.gnome.excludePackages =
    (with pkgs; [
      gnome-photos
      gnome-tour
      gedit # text editor
    ])
    ++ (with pkgs.gnome; [
      cheese # webcam tool
      gnome-music
      gnome-terminal
      epiphany # web browser
      geary # email readear
      evince # document viewer
      gnome-characters
      totem # video player
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
    ]);

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
