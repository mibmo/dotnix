{ pkgs-23_11, ... }:
{
  services.tor = {
    enable = true;
    client.enable = true;
    settings = {
      ControlPort = [ { port = 9051; } ];
      ClientUseIPv6 = true;
    };
  };

  home.packages = [ pkgs-23_11.nyx ];
}
