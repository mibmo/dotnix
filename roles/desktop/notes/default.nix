{ pkgs-24_05, ... }:
let
  logseq = pkgs-24_05.logseq.override {
    # graph doesnt sync properly; needs upstream major version (electron 27)
    #electron = pkgs.electron_29;
  };

  # path to logseq graphs relative to home
  graphs = [
    "assets/diary"
    "assets/notes"
  ];
in
{
  home = {
    packages = [ logseq ];
    settings = { lib, ... }: {
      home.activation.logseq =
        let
          globalConfig = ./global.edn;
          graphConfig = ./graph.edn;
          globalPath = "$HOME/.config/Logseq/configs.edn";
        in
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          verboseEcho "installing global config"
          run rm $VERBOSE_ARG ${globalPath}
          run cp $VERBOSE_ARG ${globalConfig} ${globalPath}

          ${lib.strings.concatMapStringsSep "\n" (graph: let
            path = "$HOME/${graph}/logseq/config.edn";
          in ''
            verboseEcho "installing per-graph config to graph at ${graph}"
            run rm $VERBOSE_ARG ${path}
            run cp $VERBOSE_ARG ${graphConfig} ${path}
          '') graphs}
        '';
    };
  };

  persist.user.directories = [
    ".config/Logseq"
    ".logseq"
  ];
}
