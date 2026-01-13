{
  config,
  host,
  lib,
  pkgs,
  specification,
  ...
}:
let
  mkJob =
    {
      name,
      repo,
      paths ? [ ],
      compression ? "lz4",
      user ? specification.user.name,
      group ? "users",
      frequency ? "daily",
      patterns ? [ ],
      prune-keep ? { },
    }:
    {
      archiveBaseName = name;
      repo =
        {
          lucoa = "ssh://u488762@u488762.your-storagebox.de:23/./${host.name}";
        }
        .${repo} or (throw "No such repository '${repo}'");
      startAt = frequency;
      dateFormat = "-u '+%Y-%m-%dT%H:%M:%S'";
      doInit = false;
      # wait till lock becomes available
      extraCreateArgs = [ "--lock-wait=1800" ];
      inherit
        user
        group
        paths
        patterns
        compression
        ;
      ${lib.dot.setIf "prune" (prune-keep != { })} = {
        prefix = "${name}-";
        keep = prune-keep;
      };
      encryption = {
        mode = "repokey";
        passCommand = "cat ${config.age.secrets."borg-${repo}-${host.name}-pass".path}";
      };
      environment."BORG_RSH" = "ssh -i ${config.age.secrets."borg-${repo}-${host.name}-key".path}";
    };
in
{
  home.packages = with pkgs; [ borgbackup ];

  services.borgbackup = {
    jobs = {
      "backup" = mkJob {
        name = "backup";
        repo = "lucoa";
        frequency = "daily";
        compression = "zstd";
        paths = "/home/${specification.user.name}/backup";
        prune-keep = {
          within = "1d";
          daily = 7;
          weekly = 4;
          monthly = 6;
        };
      };
      "books" = mkJob {
        name = "books";
        repo = "lucoa";
        frequency = "daily";
        paths = "/home/${specification.user.name}/assets/books";
        patterns = [
          ''! .stfolder*''
          ''- **/*.sync*''
          ''- **/.nextcloudsync.log''
        ];
        prune-keep.weekly = 4;
      };
      "dev" = mkJob {
        name = "dev";
        repo = "lucoa";
        frequency = "hourly";
        compression = "zstd";
        paths = "/home/${specification.user.name}/dev";
        patterns = [
          ''! .stfolder*''
          ''- **/*.sync*''
          ''- **/.nextcloudsync.log''
          ''! **/.ipynb_checkpoints''
          # archives
          ''- re:[a-zA-Z0-9]\.tar(\.(bzip|bzip2|gzip|lzma|lzma2|zstd|zstandard))?^''
          ''- **/**.dwarfs''
          ''- **/**.zip''
          # programming
          ''! **/node_modules''
          ''! **/.pnpm-store''
          ''! **/target''
          ''! **/build''
        ];
        prune-keep = {
          within = "1d";
          daily = 7;
          weekly = 4;
          monthly = 12;
        };
      };
      "diary" = mkJob {
        name = "diary";
        repo = "lucoa";
        frequency = "daily";
        compression = "zstd";
        paths = "/home/${specification.user.name}/assets/diary";
        prune-keep = {
          within = "1d";
          daily = 7;
          weekly = 4;
          monthly = 6;
        };
      };
      "documents" = mkJob {
        name = "documents";
        repo = "lucoa";
        frequency = "daily";
        compression = "zstd";
        paths = "/home/${specification.user.name}/assets/documents";
        patterns = [
          ''! .stfolder*''
          ''- **/*.sync*''
          ''- **/.nextcloudsync.log''
        ];
        prune-keep = {
          within = "1d";
          daily = 7;
          weekly = 4;
          monthly = 6;
        };
      };
      "email" = mkJob {
        name = "email";
        repo = "lucoa";
        frequency = "daily";
        paths = "/home/${specification.user.name}/.thunderbird";
        patterns = [
          # don't backup encryption keys
          ''- re:key[0-9]+.db''
          # journal files
          ''- *.db-journal''
        ];
        prune-keep = {
          within = "1d";
          daily = 7;
          weekly = 4;
          monthly = 6;
        };
      };
      "education" = mkJob {
        name = "education";
        repo = "lucoa";
        frequency = "daily";
        paths = "/home/${specification.user.name}/assets/education";
        patterns = [
          ''! .stfolder*''
          ''- **/*.sync*''
          ''- **/.nextcloudsync.log''
          ''! **/.ipynb_checkpoints''
          # latex
          ''- re:[a-zA-Z0-9]+\.(aux|dvi|fdb_latexmk|fls|log|out|synctex.gz|toc)''
          ''! **/_minted*''
          # programming
          ''! **/node_modules''
          ''! **/target''
          ''! **/build''
        ];
        prune-keep = {
          within = "1d";
          daily = 7;
          weekly = 4;
          monthly = 6;
        };
      };
      "torrents" = mkJob {
        name = "torrents";
        repo = "lucoa";
        frequency = "daily";
        compression = "zstd";
        paths = "/home/${specification.user.name}/assets/torrents";
        prune-keep = {
          within = "1d";
          daily = 7;
          weekly = 4;
          monthly = 6;
        };
      };
      "images" = mkJob {
        name = "images";
        repo = "lucoa";
        frequency = "daily";
        compression = "zstd";
        paths = "/home/${specification.user.name}/assets/images";
        patterns = [
          ''! .stfolder*''
          ''- **/*.sync*''
          ''- **/.nextcloudsync.log''
          ''- re:shuzhi-[dl]\.svg''
        ];
        prune-keep = {
          within = "1d";
          daily = 7;
          weekly = 4;
          monthly = 6;
        };
      };
      "notes" = mkJob {
        name = "notes";
        repo = "lucoa";
        frequency = "daily";
        compression = "zstd";
        paths = "/home/${specification.user.name}/assets/notes";
        prune-keep = {
          within = "1d";
          daily = 7;
          weekly = 4;
          monthly = 6;
        };
      };
      /*
        "zfs-daily-snapshots" = {
          dumpCommand = lib.getExe (
            pkgs.writeShellApplication {
              name = "get-zfs-snapshots";
              runtimeInputs = with pkgs; [
                zfs
              ];
              text = ''
                zfs list -t snapshot -pH -o name | grep "daily" | while read -r name; do
                  dataset="$(echo $name | cut -d@ -f1)"
                  snapshot="$(echo $name | cut -d@ -f2-)"
                  snapdir="$(zfs get snapdir -pH -o value "$dataset")"
                  if [[ "$snapdir" = "hidden" ]]; then
                    mountpoint="$(zfs get mountpoint -pH -o value "$dataset")"
                    if [[ "$mountpoint" = "legacy" ]]; then
                      mountpoint="$(cat /etc/fstab | grep '^data/persist' | cut -d' ' -f2)"
                    fi
                    snapdir="$mountpoint/.zfs/snapshot"
                  fi
                  echo "$snapdir/$snapshot"
                done
              '';
            }
          );
        };
      */
    };
  };

  # allow non-PQ KEX for Hetzner storageboxes
  # @TODO: check periodically if this is still necessary
  programs.ssh.extraConfig = ''
    Host *.your-storagebox.de
      KexAlgorithms +curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256
  '';
  home.settings.programs.ssh.matchBlocks."*.your-storagebox.de".kexAlgorithms = [
    "+curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256"
  ];

  age.secrets = {
    "borg-lucoa-sakamoto-pass" = {
      file = ../../secrets/borg_lucoa_sakamoto_pass;
      owner = specification.user.name;
      group = "users";
    };
    "borg-lucoa-sakamoto-key" = {
      file = ../../secrets/borg_lucoa_sakamoto_key;
      owner = specification.user.name;
      group = "users";
    };
  };

  persist.user.directories = [
    ".cache/borg"
    ".config/borg"
  ];
}
