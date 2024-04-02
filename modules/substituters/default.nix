{ lib, config, ... }: {
  options.substituters = lib.mkOption {
    type = with lib.types; listOf str;
    default = [ ];
    example = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
  };

  config.nix.settings =
    let
      substituters = map extractSubstituter config.substituters;
      extractSubstituter = key:
        let
          parts = lib.strings.splitString "-" key;
          url = "https://" +
            lib.strings.concatStringsSep
              "-"
              (lib.lists.take (lib.lists.length parts - 1) parts);
        in
        { inherit key url; };
    in
    {
      substituters = map (s: s.url) substituters;
      trusted-public-keys = map (s: s.key) substituters;
    };
}
