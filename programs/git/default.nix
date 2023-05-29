config: { lib, ... }:
let
  inherit (config) user;
  inherit (config.secret) gpg;
  parallelConnections = 16;
  extraConfig = {
    core.editor = "nvim";
    init.defaultBranch = "main";
    commit = {
      status = true;
      verbose = 1;
    };
    fetch.parallel = parallelConnections;
    http.maxRequests = parallelConnections;
    url = {
      "https://github.com/".insteadOf = "gh:";
      "ssh://git@github.com".pushInsteadOf = "gh:";
      "https://gitlab.com/".insteadOf = "gl:";
      "ssh://git@gitlab.com".pushInsteadOf = "gl:";
    };
  };
  signing = lib.mkIf (gpg ? keyId) {
    key = gpg.keyId;
    signByDefault = true;
  };
in
{
  programs.git = {
    enable = true;
    lfs.enable = true;
    delta.enable = true;

    userName = user.name;
    userEmail = user.email;
    inherit extraConfig signing;
  };
}
