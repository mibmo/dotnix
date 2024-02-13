{ lib, settings, ... }:
let
  mkEmail = account@{ address, ... }:
    let
      # allow for `meta.authentication.flavor = keepassxz/path/etc`
      config = lib.attrsets.removeAttrs account [ "meta" ];
    in
    {
      thunderbird = {
        enable = true;
        profiles = [ "default" ];
      };
    } // config;

  accounts = [ ];

  module = {
    programs.thunderbird = {
      enable = true;
      profiles.default = {
        isDefault = true;
        withExternalGnupg = true;
      };
    };

    accounts.email.accounts = lib.foldl
      (set: account: set // { ${account.address} = account; })
      { }
      accounts;
  };
in
{
  home-manager.users.${settings.user.name}.imports = [ module ];
}
