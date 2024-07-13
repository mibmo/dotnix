{ pkgs, config, settings, ... }:
let
  keybinds = {
    terminal = {
      name = "Open terminal";
      binding = "<Super>Return";
      command = "foot";
    };
  };

  ini = pkgs.formats.ini { };
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
      inherit (lib.attrsets) attrNames mapAttrs' removeAttrs;
      inherit (lib.hm.gvariant) mkUint32;

      # key is attribute name of extension in gnomeExtensions
      extensions = {
        appindicator = { };
        burn-my-windows.active-profile = "/home/${settings.user.name}/.config/burn-my-windows/profiles/main.conf";
        shu-zhi = {
          default-style = mkUint32 3;
          dark-sketch-type = mkUint32 4;
          light-sketch-type = mkUint32 4;
          color-name = mkUint32 1;
          text-command = toString shuzhiCommand;
          enable-systray = true;

          meta.dconfKey = "shuzhi";
        };
      };

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
      home = {
        file.".config/burn-my-windows/profiles/main.conf".source = ini.generate "burn-my-windows-profile" {
          burn-my-windows-profile = {
            profile-window-type = 0;
            profile-animation-type = 0;

            apparition-enable-effect = false;
            broken-glass-enable-effect = false;
            doom-enable-effect = false;
            energize-a-enable-effect = false;
            energize-b-enable-effect = false;
            fire-enable-effect = false;
            glide-enable-effect = false;
            glitch-enable-effect = false;
            hexagon-enable-effect = true;
            incinerate-enable-effect = false;
            matrix-enable-effect = false;
            paint-brush-enable-effect = false;
            pixelate-enable-effect = false;
            pixel-wheel-enable-effect = false;
            pixel-wipe-enable-effect = false;
            portal-enable-effect = false;
            snap-enable-effect = false;
            trex-enable-effect = false;
            tv-enable-effect = false;
            tv-glitch-enable-effect = false;
            wisps-enable-effect = false;

            hexagon-animation-time = 600;
            hexagon-line-color = "rgba(200,255,255,0.5)";
            hexagon-glow-color = "rgba(20,80,255,0.5)";
          };
        };
        packages = [
          config.programs.gnupg.agent.pinentryPackage
          pkgs.file-roller
        ] ++ map (name: pkgs.gnomeExtensions.${name}) (attrNames extensions);
      };

      dconf.settings = {
        "org/gnome/desktop/interface"."show-battery-percentage" = true;
        "org/gnome/desktop/wm/preferences"."focus-mode" = "sloppy";
        "org/gnome/mutter" = {
          "dynamic-workspaces" = true;
          "edge-tiling" = true;
        };
        "org/gnome/settings-daemon/plugins/color"."night-light-enable" = true;
        "org/gnome/settings-daemon/plugins/power" = {
          "ambient-enabled" = true;
          "sleep-inactive-ac-timeout" = 7200; # 2 hours
          "sleep-inactive-battery-timeout" = 300; # 5 min
        };

        "org/gnome/desktop/peripherals/touchpad"."send-events" = "disabled-on-external-mouse";

        "org/gnome/settings-daemon/plugins/media-keys" = {
          custom-keybindings = map
            keybindDir
            (attrNames keybinds);

          www = [ "<Super>w" ];
        };
        "org/gnome/desktop/wm/keybindings"."close" = [ "<Super>q" ];

        "org/gnome/shell"."enabled-extensions" = map (name: pkgs.gnomeExtensions.${name}.extensionUuid) (attrNames extensions);
      } // (mapAttrs'
        (name: value: {
          name = keybindPath name;
          inherit value;
        })
        keybinds
      ) // (
        mapAttrs'
          (name: config:
            let
              extension = pkgs.gnomeExtensions.${name};
            in
            {
              name = "org/gnome/shell/extensions/${config.meta.dconfKey or extension.extensionPortalSlug}";
              value = removeAttrs config [ "meta" ];
            })
          extensions
      );
    };
}
