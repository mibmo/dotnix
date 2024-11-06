{ ... }:
{
  services.tailscale = {
    enable = true;
    openFirewall = true;
    extraUpFlags = [
      "--login-server=https://headscale.kanp.ai"
      "--accept-dns=false"
    ];
  };

  persist.directories = [
    {
      directory = "/var/lib/tailscale";
      mode = "700";
      user = "root";
      group = "root";
    }
  ];
}
