{ ... }:
{
  services.i2pd = {
    enable = true;
    yggdrasil.enable = true;
    proto = {
      httpProxy.enable = true;
      sam.enable = true;
    };
  };
}
