{
  config,
  lib,
  pkgs,
  specification,
  ...
}:
{
  imports = [ ../. ];

  services = {
    dbus.packages = with pkgs; [
      dconf
      gcr
    ];
    udev.packages = [ pkgs.cosmic-settings-daemon ];

    desktopManager.cosmic = {
      enable = true;
      xwayland = true;
    };
    displayManager.cosmic-greeter.enable = true;
  };

  # dont install default applications
  services.desktopManager.cosmic.showExcludedPkgsWarning = true;
  /*
    environment.cosmic.excludePackages = with pkgs; [
      cosmic-player # video player
    ];
  */

  /*
    home.settings =
      { lib, ... }:
      let
        inherit (lib.attrsets) attrNames mapAttrs' removeAttrs;
        inherit (lib.hm.gvariant) mkUint32;

        # key is attribute name of extension in gnomeExtensions
        extensions = {
          appindicator = { };
          burn-my-windows.active-profile = "/home/${specification.user.name}/.config/burn-my-windows/profiles/main.conf";
        };

        keybindPath = name: "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${name}";
        keybindDir = name: "/${keybindPath name}/";
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

        dconf.settings =
          {
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

            "org/gnome/desktop/peripherals/mouse"."accel-profile" = "flat";
            "org/gnome/desktop/peripherals/touchpad"."send-events" = "disabled-on-external-mouse";

            "org/gnome/settings-daemon/plugins/media-keys" = {
              custom-keybindings = map keybindDir (attrNames keybinds);

              www = [ "<Super>w" ];
            };
            "org/gnome/desktop/wm/keybindings"."close" = [ "<Super>q" ];

            "org/gnome/shell"."enabled-extensions" = map (name: pkgs.gnomeExtensions.${name}.extensionUuid) (
              attrNames extensions
            );
          }
          // (mapAttrs' (name: value: {
            name = keybindPath name;
            inherit value;
          }) keybinds)
          // (mapAttrs' (
            name: config:
            let
              extension = pkgs.gnomeExtensions.${name};
            in
            {
              name = "org/gnome/shell/extensions/${config.meta.dconfKey or extension.extensionPortalSlug}";
              value = removeAttrs config [ "meta" ];
            }
          ) extensions);
      };
  */

  # gnome handles tablets
  hardware.opentabletdriver.enable = lib.mkForce false;
}
