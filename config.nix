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
        ./roles/internet/thunderbird
        ./roles/internet/syncthing
        ./roles/internet/i2p
        ./roles/internet/ipfs
      ];
    };

    macadamia = {
      name = "macadamia";
      system = "x86_64-linux";
      host = ./hosts/macadamia;
      roles = [
        hardwareModules.apple-macbook-pro-14-1
        ./roles/desktop/gnome
      ];
      keys.ssh = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUJBjmqie6MuzMpkvw8k/SoEZ8dHcWDNggVVanyqYqE" ];
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
    aliases =
      let
        dotnixDir = "~/dev/dotnix";
      in
      rec {
        e = defaults.editor;
        se = "sudo ${e}";
        ns = "nom shell";
        nd = "nom develop";
        lsblk = "lsblk -o NAME,SIZE,TYPE,FSTYPE,FSVER,MOUNTPOINTS";
        build = "nom build ${dotnixDir}#nixosConfigurations.$hostname.config.system.build.toplevel --no-link";
        switch = "sudo nixos-rebuild switch --flake ${dotnixDir}#$hostname";
        rebuild = "${build} && ${switch}";
        rebuild-offline = "${build} --offline && ${switch} --offline";
        tmp = "pushd $(mktemp -d)";
        cleanup-results = ''find . -type l -name "result*" -exec echo "unlinking {}" \; -exec unlink {} \;'';
        gc-nix = "nix-env --delete-generations +3 && nix store gc --verbose && nix store optimise --verbose";
      };
  };

  gpg = {
    #keyId = "";
  };

in
{
  inherit hosts user defaults shell gpg;
}
