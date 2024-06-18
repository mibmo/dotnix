{ lib, ... }:
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
in
{
  home.settings = {
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

  persist.user.directories = [
    ".thunderbird"
    ".cache/thunderbird"
  ];
}
