{ ... }: {
  services.i2pd = {
    enable = true;
    yggdrasil.enable = true;
    proto.socksProxy.enable = true;
  };
}
