{ pkgs-23_11, ... }:
{
  services.tor = {
    enable = true;
    client.enable = true;
    settings.ControlPort = [ { port = 9051; } ];
  };

  home.packages = [ pkgs-23_11.nyx ];
}
