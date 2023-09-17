{ inputs, lib }:
let
  hardwareModules = inputs.nixos-hardware.nixosModules;
  hosts = {
    hamilton = {
      name = "hamilton";
      system = "x86_64-linux";
      host = ./hosts/hamilton;
      roles = [
        hardwareModules.asus-zephyrus-ga502
        ./roles/dev
        ./roles/gaming
        ./roles/desktop
        ./roles/education
        ./roles/productivity

        ./roles/desktop/gnome
        ./roles/internet/syncthing
        ./roles/internet/i2p
        ./roles/internet/ipfs
      ];
    };
  };

  user = {
    name = "mib";
    email = "mib@mib.dev";
  };

  defaults = {
    editor = "nvim";
  };

  shell = {
    aliases = rec {
      e = defaults.editor;
      se = "sudo ${e}";
      ns = "nix-shell";
      nd = "nix develop";
      lsblk = "lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS";
      rebuild = "sudo nixos-rebuild switch --flake ~/dev/dotnix#$hostname";
      rebuild-offline = "${rebuild} --offline";
      tmp = "pushd $(mktemp -d)";
      cleanup-results = ''find . -type l -name "result" -exec echo "unlinking {}" \; -exec unlink {} \;'';
    };
  };

  gpg = {
    #keyId = "";
  };

in
{
  inherit hosts user defaults shell gpg;
}
