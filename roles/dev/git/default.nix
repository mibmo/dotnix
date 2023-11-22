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
    push.autoSetupRemote = true;
    fetch.parallel = parallelConnections;
    http.maxRequests = parallelConnections;
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

  module = {
    programs.git = {
      enable = true;
      lfs.enable = true;
      delta.enable = true;

      userName = settings.user.name;
      userEmail = settings.user.email;
      inherit extraConfig signing;
    };
  };
in
{
  home-manager.users.${settings.user.name}.imports = [ module ];
}
