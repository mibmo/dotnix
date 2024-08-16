{ pkgs, ... }:
let
  logseq = pkgs.logseq.override {
    # graph doesnt sync properly; needs upstream major version (electron 27)
    #electron = pkgs.electron_29;
  };
in
{
  home.packages = [ logseq ];

  persist.user.directories = [
    ".config/Logseq"
  ];
}
