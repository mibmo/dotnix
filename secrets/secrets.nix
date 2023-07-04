let
  lafayette = "age1e007kgnn4e2g0mtzvy5vdepujzfkz6v6hqh6aqa4655l62jcpgnsxv769h";

  keys = [ lafayette ];

  mkSecret = name: { ${name}.publicKeys = keys; };
  secrets = [
    "user_password"
    "aur_private_key"
    "github_private_key"
    "scaleway_private_key"
  ];
in
builtins.foldl'
  (l: r: l // r)
{ }
  (map mkSecret secrets)
