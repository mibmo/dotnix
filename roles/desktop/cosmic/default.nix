{
  lib,
  pkgs,
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
      xwayland.enable = true;
    };
    displayManager.cosmic-greeter.enable = true;
  };

  # dont install default applications
  environment.cosmic.excludePackages = with pkgs; [
    cosmic-edit # text editor
    cosmic-icons # icon theme
    cosmic-player # video player
    cosmic-randr # configure wayland outputs
    cosmic-screenshot # screenshots
    cosmic-term # terminal
    cosmic-wallpapers # wallpapers
  ];

  # cosmic handles tablets (probably?)
  hardware.opentabletdriver.enable = lib.mkForce false;
}
