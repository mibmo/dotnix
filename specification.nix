{
  inputs,
  lib,
  ...
}:
let
  inherit (lib.dot) applyHosts;

  hardwareModules = inputs.nixos-hardware.nixosModules;
  hosts = applyHosts {
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
      "flagfox"
      "geogebra"
      "osu-lazer(-bin)?"
      "steam(-(run|original|unwrapped))?"
    ];
    stable = [
      "canon-cups-ufr2"
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
        ignore-builders = ''--option builders "" --option substituters "$(jq -r '[.[].host | select(contains("kanpai") | not) | "https://\(.)"] | join(" ")' /etc/substituters)"'';
      in
      rec {
        e = defaults.editor;
        se = "sudo ${e}";
        ns = "nom shell";
        nd = "nom develop";
        nd-no-builders = "${nd} ${ignore-builders}";
        lsblk = "lsblk -o NAME,SIZE,TYPE,FSTYPE,FSVER,MOUNTPOINTS";
        build = "${inhibit} nom build ${dotnixDir}#nixosConfigurations.$(hostname).config.system.build.toplevel --out-link /tmp/nixos-configuration && nvd diff /run/current-system /tmp/nixos-configuration";
        build-no-builders = "${inhibit} nom build ${dotnixDir}#nixosConfigurations.$(hostname).config.system.build.toplevel --out-link /tmp/nixos-configuration && nvd diff /run/current-system /tmp/nixos-configuration";
        switch = "${inhibit} sudo nixos-rebuild switch --flake ${dotnixDir}#$(hostname)";
        switch-no-builders = "${inhibit} sudo nixos-rebuild switch --flake ${dotnixDir}#$(hostname) ${ignore-builders}";
        rebuild = "${build} && ${inhibit} sudo /tmp/nixos-configuration/bin/switch-to-configuration switch";
        rebuild-no-builders = "${build-no-builders} && ${inhibit} sudo /tmp/nixos-configuration/bin/switch-to-configuration switch ${ignore-builders}";
        rebuild-offline = "${build} --offline && ${switch} --offline";
        tmp = "pushd $(mktemp -d)";
        gc-nix = "${inhibit} nix-env --delete-generations +3 && nix store gc --verbose && nix store optimise --verbose";
        inhibit = "gnome-session-inhibit";
        edushell = "nom develop $HOME/assets/education/shell";
        edushell-offline = "${edushell} --offline";
        edushell-no-builders = "${edushell} ${ignore-builders}";
      };

    functions = {
      # Find directory in dev folder based on search and cd into it
      dev =
        let
          fdOpts = "--type=directory --full-path ~/dev/nixpkgs/*";
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
      # @TODO: move all these elsewhere to allow using `pkgs`
      /*
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
      */
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
