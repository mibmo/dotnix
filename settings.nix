let
  config = {
    user = rec {
      name = "mib";
      home = "/home/${name}"; # @TODO: support darwin
      email = "mib@kanp.ai";
    };
    secret = {
      gpg = {
        keyId = "AB0DC647B2F786EB045C7EFECF6E67DED6DC1E3F";
      };
    };
    system = {
      wm = "gnome";
    };
    shell = {
      name = "fish";
      inherit aliases;
    };
  };
  aliases = rec {
    rebuild = "sudo nixos-rebuild switch --flake ~/dev/dotnix#$hostname";
    rebuild-offline = rebuild + " --offline";
    lsblk = "lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS";
  };
in
config
