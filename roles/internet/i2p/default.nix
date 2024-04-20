{ ... }: {
  services.i2pd = {
    enable = true;
    yggdrasil.enable = true;
    proto.httpProxy.enable = true;
    reseed.urls = [
      "reseed2.i2p.net"
      "i2phides.me"
      "www2.mk16.de"
    ];
  };
}
