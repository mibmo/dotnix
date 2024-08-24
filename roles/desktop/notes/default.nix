{ pkgs, ... }:
let
  logseq = pkgs.logseq.override {
    # graph doesnt sync properly; needs upstream major version (electron 27)
    #electron = pkgs.electron_29;
  };

  # path to logseq graphs relative to home
  graphs = [
    "assets/diary"
    "assets/notes"
  ];

  globalConfig = ./global.edn;
  graphConfig = ./graph.edn;
in
{
  home = {
    packages = [ logseq ];
    settings = { lib, ... }: {
      home.activation.logseq = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        # logseq global config
        verboseEcho "logseq: installing global config"
        run cp ${globalConfig} $HOME/.config/Logseq/configs.edn

        # logseq per-graph configs
        ${lib.strings.concatMapStringsSep "\n" (path: ''
          verboseEcho "logseq: installing per-graph config to graph at $HOME/${path}"
          run cp ${graphConfig} $HOME/${path}/logseq/config.edn
        '') graphs}
      '';
    };
  };

  persist.user.directories = [
    ".config/Logseq"
    ".logseq"
  ];
}
