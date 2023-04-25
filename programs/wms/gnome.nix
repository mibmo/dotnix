user: { config, pkgs, ... }:
let
  inherit (pkgs.lib) mkIf;
in
{
  programs.gnupg.agent.pinentryFlavor = "gnome3";

  services = {
    dbus.packages = [ pkgs.dconf ];
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
    # top bar
    appindicator
    keep-awake
    time-awareness
    vitals

    # looks
    burn-my-windows
    undecorate
    shu-zhi

    (mkIf config.services.mullvad-vpn.enable mullvad-indicator) 
  ];

  # dont install default gnome applications
  environment.gnome.excludePackages =
    (with pkgs; [
      gnome-photos
      gnome-tour
    ])
    ++ (with pkgs.gnome; [
      cheese # webcam tool
      gnome-music
      gnome-terminal
      gedit # text editor
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

  home-manager.users.${user.name}.imports = [
    (
      { ... }: {
        xdg.configFile."shuzhi.sh" = {
          executable = true;
          source = builtins.toFile "shuzhi.sh" ''
            #!/usr/bin/env sh
            echo "こんにちは"
            hostname
          '';
        };
      }
    )
  ];
}
