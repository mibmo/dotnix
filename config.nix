args@{ inputs, lib ? args.pkgs.lib, pkgs ? { } }:
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
        ./roles/education
        ./roles/productivity

        ./roles/desktop/gnome
        ./roles/internet/thunderbird
        ./roles/internet/syncthing
        ./roles/internet/ipfs
      ];
      keys.ssh = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO5JejZv7d0tOG1QXxbHVt4qhp8nMpOfSGTMsL/l98kf" ];
    };

    macadamia = {
      name = "macadamia";
      system = "x86_64-linux";
      host = ./hosts/macadamia;
      roles = [
        hardwareModules.apple-macbook-pro-14-1
        ./roles/dev
        ./roles/productivity

        ./roles/desktop/gnome
        ./roles/internet/thunderbird
        ./roles/internet/syncthing
        ./roles/internet/ipfs
      ];
      keys.ssh = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPnTI64CyDnCoQFZKWI0T1Z6YcyVW8XrJypWxD9HdMGW" ];
    };

    sakamoto = {
      name = "sakamoto";
      system = "x86_64-linux";
      host = ./hosts/sakamoto;
      roles = [
        hardwareModules.framework-16-7040-amd
        ./roles/dev
        ./roles/productivity

        ./roles/desktop/gnome
        ./roles/internet/thunderbird
        ./roles/internet/syncthing
        ./roles/internet/ipfs
      ];
      keys.ssh = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBPQ3PpMq59iLXy5j/r/mwTlrZsU2xhyDtTXdHv6yM7b" ];
    };
  };

  user = {
    name = "mib";
    email = "mib@kanp.ai";
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
        build = "nom build ${dotnixDir}#nixosConfigurations.$(hostname).config.system.build.toplevel --out-link /tmp/nixos-configuration && nvd diff /run/current-system /tmp/nixos-configuration";
        switch = "sudo nixos-rebuild switch --flake ${dotnixDir}#$(hostname)";
        rebuild = "${build} && sudo /tmp/nixos-configuration/bin/switch-to-configuration switch";
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
