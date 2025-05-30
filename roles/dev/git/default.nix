{
  lib,
  specification,
  ...
}:
let
  parallelConnections = 16;
  extraConfig = {
    core = {
      editor = specification.defaults.editor;
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
    filter.ignore-marked-lines = {
      clean = "sed -E '/@ignore(: .+)?$/d'";
      smudge = "cat";
    };
  };
  signing = lib.mkIf (specification.gpg ? keyId) {
    key = specification.gpg.keyId;
    signByDefault = true;
  };
  ignores = [
    "*sync-conflict-*-*-*"
    ".gitconfig"
  ];
  includes = map (name: {
    path = "~/dev/${name}/.gitconfig";
    condition = "gitdir:~/dev/${name}/";
  }) (import ./organizations.nix);
  attributes =
    let
      all = lib.lists.flatten [
        programming
        configuration
      ];
      programming = [
        "c"
        "cpp"
        "cs"
        "css"
        "fish"
        "go"
        "htm"
        "html"
        "java"
        "js"
        "kt"
        "kts"
        "less"
        "lisp"
        "md"
        "nix"
        "pl"
        "py"
        "r"
        "rs"
        "scss"
        "sh"
        "svg"
        "ts"
        "txt"
        "zsh"
      ];
      configuration = [
        "conf"
        "ini"
        "toml"
        "yaml"
      ];

      mkFilter =
        {
          attributes,
          filetypes ? all,
        }:
        map (filetype: "*.${filetype} ${attributes}") filetypes;
    in
    lib.flatten (
      map mkFilter [
        { attributes = "text"; }
        { attributes = "eol=lf"; }
        { attributes = "filter=ignore-marked-lines"; }
      ]
    );
in
{
  home.settings.programs.git = {
    enable = true;
    lfs.enable = true;
    delta.enable = true;

    userName = specification.user.name;
    userEmail = specification.user.email;
    inherit
      attributes
      extraConfig
      ignores
      includes
      signing
      ;
  };
}
