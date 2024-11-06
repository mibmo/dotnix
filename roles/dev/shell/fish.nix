{
  lib,
  pkgs,
  config,
  settings,
  ...
}:
let
  inherit (builtins) readFile;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.strings) concatMapStringsSep;

  shellCommands =
    let
      transpileFunction =
        name: body:
        pkgs.stdenv.mkDerivation {
          name = "${name}.fish";
          src = ''
            function ${name}() {
              ${body}
            }
          '';

          nativeBuildInputs = [ pkgs.babelfish ];

          buildPhase = ''
            echo "$src" | babelfish > script.fish
          '';
          installPhase = ''
            cp script.fish $out
          '';

          dontUnpack = true;
        };
    in
    mapAttrsToList transpileFunction settings.shell.functions;

  shellInit = ''
    set fish_greeting

    function __is_project_dir
      set  $status
    end

    # transpiled functions
    ${concatMapStringsSep "\n" readFile shellCommands}
  '';

  shellAbbrs = settings.shell.aliases // { };

  plugins =
    with pkgs.fishPlugins;
    map (attrs: { inherit (attrs) name src; }) [
      pure
      sponge
      autopair
    ];
in
{
  home.settings = {
    programs.fish = {
      enable = true;
      interactiveShellInit = "${lib.getExe pkgs.any-nix-shell} fish --info-right | source";
      inherit shellInit shellAbbrs plugins;
    };
  };

  programs.fish.enable = true;

  persist.user.directories = [ ".local/share/fish" ];
}
