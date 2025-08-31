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
      ...
    }:
    {
      archiveBaseName = name;
      repo =
        {
          luca = "ssh://u488762@u488762.your-storagebox.de:23/./${host.name}";
        }
        .${repo} or (throw "No such repository '${repo}'");
      startAt = frequency;
      dateFormat = "-u '+%Y-%m-%dT%H:%M:%S'";
      doInit = false;
      # wait till lock becomes available
      extraCreateArgs = [ "--lock-wait=600" ];
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
      "books" = mkJob {
        name = "books";
        repo = "luca";
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
        repo = "luca";
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
          monthly = 6;
        };
      };
      "education" = mkJob {
        name = "education";
        repo = "luca";
        frequency = "hourly";
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
    };
  };

  age.secrets = {
    "borg-luca-sakamoto-pass" = {
      file = ../../secrets/borg_luca_sakamoto_pass;
      owner = specification.user.name;
      group = "users";
    };
    "borg-luca-sakamoto-key" = {
      file = ../../secrets/borg_luca_sakamoto_key;
      owner = specification.user.name;
      group = "users";
    };
  };

  persist.user.directories = [
    ".cache/borg"
    ".config/borg"
  ];
}
