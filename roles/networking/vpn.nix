{ ... }: {
  services.tailscale = {
    enable = true;
    openFirewall = true;
    extraUpFlags = [
      "--login-server=https://headscale.kanp.ai"
      "--accept-dns=false"
    ];
  };
}
