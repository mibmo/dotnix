{ ... }:
{
  persist = {
    directories = [
      # logs
      "/var/log"
      # must persist for nixos UID/GID selection to work
      "/var/lib/nixos"
      # core dumps
      "/var/lib/systemd/coredump"
    ];
    files = [
      "/etc/machine-id"
    ];
    user.directories = [
      ".local/state/nix"
      "assets"
      "backup"
      {
        directory = ".ssh";
        mode = "0700";
      }
    ];
  };
}
