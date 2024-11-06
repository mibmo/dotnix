{ lib, ... }:
{
  services.zfs = {
    autoSnapshot = {
      enable = true;
      frequent = lib.mkDefault 4;
      hourly = lib.mkDefault 24;
      daily = lib.mkDefault 7;
      weekly = lib.mkDefault 4;
      monthly = lib.mkDefault 12;
    };

    autoScrub = {
      enable = true;
      interval = "daily";
    };
    trim = {
      enable = true;
      interval = "daily";
    };
  };
}
