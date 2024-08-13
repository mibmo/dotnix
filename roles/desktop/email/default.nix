{ lib, clib, ... }:
let
  inherit (clib) setIf;
  inherit (lib.attrsets) mapAttrs recursiveUpdate;

  mkEmail = address: account@{ ... }:
    let
      # allow for `meta` attribute
      config = lib.attrsets.removeAttrs account [ "meta" ];
      meta = config.meta or { };
      auth = meta.authentication or { };

      passwordCommand = {
        # @TODO: prompt-pw through `dialog` or smth...
        #keepassxc = "prompt-pw | keepassxc-cli show ~/.secret/Passwords.kdbx --attributes Password '${auth.entry}'";
      }.${toString auth.flavor} or null;
    in
    recursiveUpdate
      {
        # sane default
        inherit address;
        userName = address;
        thunderbird = {
          enable = true;
          profiles = [ "default" ];
        };
        ${setIf "passwordCommand" (meta ? authentication)} = passwordCommand;
      }
      config;

  accounts = mapAttrs mkEmail {
    "mib@kanp.ai" = {
      primary = true;
      realName = "mib";
      imap = {
        tls.useStartTls = true;
        host = "mail.kanp.ai";
        port = 143;
      };
      smtp = {
        tls.useStartTls = true;
        host = "mail.kanp.ai";
        port = 587;
      };
    };
    "s245244@dtu.dk" = {
      realName = "RTS";
      flavor = "outlook.office365.com";
      thunderbird.settings = id: {
        # auth via oAuth2
        "mail.smtpserver.smtp_${id}.authMethod" = 3;
      };
      meta.authentication = {
        flavor = "keepassxc";
        entry = "DTU/Microsoft";
      };
    };
  };
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

    accounts.email.accounts = accounts;
  };

  persist.user.directories = [
    ".thunderbird"
  ];
}
