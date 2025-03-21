{ lib, config, ... }:
{
  # use a proper submodule so that s3 support can be added without extreme jank
  #   str -> coercible into a https substituter
  #   submodule -> some substituer (s3, https, etc)
  # probably kill /etc/substituters. it's useful for debugging but only janky now
  options.substituters = lib.mkOption {
    type =
      with lib.types;
      listOf (oneOf [
        str
        attrs
      ]);
    default = [ ];
    example = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
  };

  config =
    let
      inherit (builtins) elemAt match;
      inherit (lib.lists) filter reverseList;
      inherit (lib.strings) concatStrings stringToCharacters;

      reverse =
        text: if text != null then concatStrings (reverseList (stringToCharacters text)) else null;

      substituters = map (
        s:
        lib.attrsets.filterAttrs (_: v: v != null) (
          if builtins.isAttrs s then
            s
          else
            let
              matches = match "(([a-z]+)://)?(.*):([a-zA-Z0-9+/=]+)" s;
              hostParts = match "(([0-9]+)-)?(.*)" (reverse (elemAt matches 2));

              protocol = elemAt matches 1;
              host = reverse (elemAt hostParts 2);
              suffix = reverse (elemAt hostParts 1);
              key = elemAt matches 3;
            in
            {
              inherit
                matches
                hostParts
                protocol
                host
                suffix
                key
                ;
            }
        )
      ) config.substituters;
    in
    {
      nix.settings = {
        substituters = map (s: "${s.protocol or "https"}://${s.host}") substituters;
        trusted-public-keys = map (
          s: "${s.host}${lib.optionalString (s ? "suffix") "-${s.suffix}"}:${s.key}"
        ) (filter (s: s ? "key") substituters);
      };

      environment.etc.substituters.text = builtins.toJSON substituters;
    };
}
