{ pkgs, config, ... }:
let
  keybinds = {
    terminal = {
      name = "Open terminal";
      binding = "<Super>Return";
      command = "foot";
    };
  };
in
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

  home.settings = { lib, ... }:
    let
      inherit (lib.attrsets) attrNames mapAttrs';
      inherit (lib.hm.gvariant) mkUint32;

      keybindPath = name: "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${name}";
      keybindDir = name: "/${keybindPath name}/";

      shuzhiCommand = pkgs.writeScript "shuzhi.py" ''
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
    in
    {
      dconf.settings = {
        "org/gnome/desktop/interface"."show-battery-percentage" = true;
        "org/gnome/desktop/wm/preferences"."focus-mode" = "sloppy";
        "org/gnome/mutter"."edge-tiling" = true;
        "org/gnome/settings-daemon/plugins/color"."night-light-enable" = true;
        "org/gnome/settings-daemon/plugins/power" = {
          "ambient-enabled" = true;
          "sleep-inactive-ac-timeout" = 7200; # 2 hours
          "sleep-inactive-battery-timeout" = 300; # 5 min
        };

        "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = map
          keybindDir
          (attrNames keybinds);

        "org/gnome/desktop/peripherals/touchpad"."send-events" = "disabled-on-external-mouse";

        "org/gnome/shell"."enabled-extensions" = [ "shuzhi@tuberry" ];
        "org/gnome/shell/extensions/shuzhi" = {
          "default-style" = mkUint32 3;
          "dark-sketch-type" = mkUint32 4;
          "light-sketch-type" = mkUint32 4;
          "color-name" = mkUint32 1;
          "text-command" = toString shuzhiCommand;
          "enable-systray" = true;
        };
      } // (mapAttrs'
        (name: value: {
          name = keybindPath name;
          inherit value;
        })
        keybinds
      );
    };
}
