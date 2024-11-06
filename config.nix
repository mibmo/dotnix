args@{
  inputs,
  lib ? args.pkgs.lib,
  pkgs ? { },
}:
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
        ./roles/desktop/email
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
        ./roles/desktop/email
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
        ./roles/gaming
        ./roles/education
        ./roles/productivity

        ./roles/desktop/gnome
        ./roles/desktop/email
        ./roles/internet/syncthing
        ./roles/internet/ipfs
      ];
      keys.ssh = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBPQ3PpMq59iLXy5j/r/mwTlrZsU2xhyDtTXdHv6yM7b" ];
    };
  };

  # "release" = [ "pkgs-0.1.0" "to-0.2.0" "allow-0.3.0];
  # i.e. `"23.11" = [ "hello-2.12.1" ];`
  permittedInsecurePackages = {
    "24.05" = [ "electron-27.3.11" ];
  };

  # "release" = [ "pkgs-0.1.0" "to-0.2.0" "allow-0.3.0];
  # i.e. `"23.11" = [ "hello-2.12.1" ];`
  # the entries are regex patterns
  permittedUnfreePatterns = {
    unstable = [
      "canon-cups-ufr2"
      "drawio"
      "flagfox"
      "geogebra"
      "steam(-(run|original|unwrapped))?"
    ];
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
        gc-nix = "nix-env --delete-generations +3 && nix store gc --verbose && nix store optimise --verbose";
      };

    functions = {
      # Find directory in dev folder based on search and cd into it
      dev =
        let
          fdOpts = "--type=directory --full-path --exclude nixpkgs";
        in
        ''
          cd $(fzf \
            --bind 'start:reload:fd "" ~/dev ${fdOpts}' \
            --bind 'change:reload:fd {q} ~/dev ${fdOpts} || true' \
            --preview='tree -CL 2 {}' \
            --height=50% --layout=reverse \
            --query "$argv")
        '';
      # killall, but works wrapped programs
      killall-nix = ''
        name="$1"
        shift
        for pid in $(pgrep "$name"); do
          echo "killing $pid";
          kill "$@" "$pid";
        done
      '';
      # unlink result symlinks
      cleanup-results =
        let
          cleanup = pkgs.writeShellScript "cleanup.sh" ''
            for link in "$@"
            do
              target=$(readlink -f "$link")
              printf "\n%s -> %s" "$link" "$target"
              case $target in "/nix/store/"*)
                printf " [unlinked]"
                unlink "$link"
              esac
            done
          '';
        in
        ''fd '^result(-[a-zA-Z]+)?$' --type symlink --unrestricted --exec-batch ${cleanup}'';
    };
  };

  gpg = {
    #keyId = "";
  };

in
{
  inherit
    hosts
    user
    defaults
    shell
    gpg
    ;
  inherit permittedInsecurePackages permittedUnfreePatterns;
}
