{ pkgs, ... }:
let
  logseq = pkgs.logseq.override {
    # graph might not sync properly
    electron = pkgs.electron_29;
  };
in
{
  home.packages = [ logseq ];

  persist.user.directories = [
    ".config/Logseq"
  ];
}
