let
  flake = builtins.getFlake (toString ./..);
  inherit (flake) lib;

  specification = import ../specification.nix {
    inherit (flake) inputs lib;
  };

  inherit (lib.attrsets) collect recursiveUpdate;
  inherit (lib.lists) foldl foldr;
  inherit (builtins) typeOf mapAttrs;

  getKeys = m: (m.keys.ssh or [ ]) ++ (m.keys.age or [ ]);
  foldKeys = foldl (acc: m: acc ++ getKeys m) [ ];
  keys = [ lafayette ] ++ foldKeys (collect (c: c ? name) specification.hosts);

  lafayette = "age1e007kgnn4e2g0mtzvy5vdepujzfkz6v6hqh6aqa4655l62jcpgnsxv769h";

  mkSecret = name: { ${name}.publicKeys = keys; };
  secrets = [
    "user_password"
    "aur_private_key"
    "github_private_key"
    "scaleway_private_key"
    "syncthing_hamilton_key"
    "syncthing_hamilton_cert"
    "syncthing_macadamia_key"
    "syncthing_macadamia_cert"
    "syncthing_sakamoto_key"
    "syncthing_sakamoto_cert"
    "remotebuilder_hamilton"
    "remotebuilder_macadamia"
    "remotebuilder_sakamoto"
    "borg_lucoa_sakamoto_key"
    "borg_lucoa_sakamoto_pass"
  ];
in
builtins.foldl' (l: r: l // r) { } (map mkSecret secrets)
