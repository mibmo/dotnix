{ lib, config, ... }:
let
  cfg = config.services.fprintd;
in
{
  persist.directories = lib.optional cfg.enable {
    directory = "/var/lib/fprint";
    user = "root";
    group = "root";
  };
}
