{ ... }: {
  programs = {
    hyprland.enable = true;
    gnupg.agent.pinentryFlavor = "qt";
  };

  # might need gdm? maybe enable that, but not gnome?

  /*
    services = {
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
  */


  # might need this for nvidia
  #hardware.nvidia.modesetting.enable = true;
}
