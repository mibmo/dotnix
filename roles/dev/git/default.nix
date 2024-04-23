{ lib, pkgs, settings, ... }:
let
  parallelConnections = 16;
  extraConfig = {
    core = {
      editor = settings.defaults.editor;
      untrackedCache = true;
    };
    init.defaultBranch = "main";
    commit = {
      status = true;
      verbose = 1;
    };
    branch.sort = "-committerdate";
    column.ui = "auto";
    push.autoSetupRemote = true;
    fetch.parallel = parallelConnections;
    http.maxRequests = parallelConnections;
    rerere.enabled = true;
    url = {
      "https://github.com/".insteadOf = "gh:";
      "ssh://git@github.com".pushInsteadOf = "gh:";
      "https://gitlab.com/".insteadOf = "gl:";
      "ssh://git@gitlab.com".pushInsteadOf = "gl:";
    };
  };
  signing = lib.mkIf (settings.gpg ? keyId) {
    key = settings.gpg.keyId;
    signByDefault = true;
  };
  includes = map
    (name: {
      path = "~/dev/${name}/.gitconfig";
      condition = "gitdir:~/dev/${name}/";
    })
    (import ./organizations.nix);
in
{
  home.settings.programs.git = {
    enable = true;
    lfs.enable = true;
    delta.enable = true;

    userName = settings.user.name;
    userEmail = settings.user.email;
    inherit extraConfig signing includes;
  };
}
