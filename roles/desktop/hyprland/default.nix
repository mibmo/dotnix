{
  host,
  inputs,
  lib,
  ...
}:
let
  inherit (lib.lists) flatten genList;

  hyprPkgs = inputs.hyprland.packages.${host.system};
in
{
  imports = [ ../. ];

  programs.hyprland = {
    enable = true;
    package = hyprPkgs.hyprland;
    portalPackage = hyprPkgs.xdg-desktop-portal-hyprland;
  };

  home.settings = {
    wayland.windowManager.hyprland = {
      enable = true;
      package = null;
      portalPackage = null;
      settings = {
        "$mod" = "SUPER";

        monitor = ", preferred, auto, 1";

        input = {
          touchpad = {
            drag_3fg = 1; # 3-finger drag
            natural_scroll = true;
          };
        };

        decoration = {
          rounding = 5;
          active_opacity = 1.0;
          inactive_opacity = 1.0;

          blur = {
            enabled = true;
            ignore_opacity = false;
          };
        };

        binds = {
          drag_threshold = 10; # fire drag event after n pixels
        };

        bind =
          let
            workspaces = genList (
              i:
              let
                ws = i + 1;
              in
              [
                "$mod, code:1${toString i}, workspace, ${toString ws}"
                "$mod SHIFT, code:1${toString i}, movetoworkspacesilent, ${toString ws}"
              ]
            ) 9;
          in
          flatten (
            [
              "$mod, Q, killactive"
              "$mod, F, fullscreen, 0"
              "$mod, TAB, cyclenext, visible hist"
              "$mod SHIFT, TAB, cyclenext, visible hist prev"

              # applications
              "$mod, W, exec, firefox"
              "$mod, RETURN, exec, foot"
            ]
            ++ workspaces
          );

        bindm = [
          "$mod, mouse:272, movewindow" # move drag
          "$mod SHIFT, mouse:272, resizewindow" # resize drag
        ];
        bindc = [
          "$mod, mouse:272, togglefloating" # tap to float
        ];
      };
    };

    # widgets
    /*
      programs.quickshell = {
        enable = true;
        systemd.enable = true;
      };
    */

    # notifications
    services.fnott = {
      #enable = true;
    };
  };

}
