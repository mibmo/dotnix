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
in
{
  home = {
    packages = [ logseq ];
    settings.home.file =
      { ".config/Logseq/configs.edn".source = ./global.edn; } //
      (builtins.listToAttrs
        (
          map
            (path: {
              name = "${path}/logseq/config.edn";
              value.source = ./graph.edn;
            })
            graphs
        ));
  };

  persist.user.directories = [
    ".config/Logseq"
    ".logseq"
  ];
}
