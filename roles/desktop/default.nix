{
  lib,
  pkgs,
  pkgs-stable,
  ...
}:
let
  vnc-script = pkgs.writeShellScript "vnc" ''
    ${lib.getExe' pkgs.tigervnc "vncviewer"} &
    # run while vncviewer is open
    while [[ -n "$(jobs -r)" ]]; do
      sleep 1
      # get all VNC-related windows and disable decorations
      ${lib.getExe pkgs.wmctrl} -ulp | grep "VNC" | cut -d" " -f1 | while read -r xid; do
        ${lib.getExe pkgs.xorg.xprop} -id "$xid" -format _MOTIF_WM_HINTS 32c -set _MOTIF_WM_HINTS 2
      done
    done
  '';

  vnc-viewer = pkgs.tigervnc.overrideAttrs (prev: {
    postInstall = ''
      ${prev.postInstall}
      sed -i '/^Exec=/c Exec=${vnc-script}' "$out/share/applications/vncviewer.desktop"
    '';
  });
in
{
  imports = [
    ./crypto
    ./fcitx5
    ./fonts
    ./stylix.nix
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
      libreoffice
      pulsemixer
      tor-browser
      vnc-viewer
    ];
  };

  programs.dconf.enable = true;

  services = {
    pulseaudio.enable = false;
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
      drivers = with pkgs-stable; [
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
