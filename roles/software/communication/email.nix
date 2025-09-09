{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.dot) setIf;
  inherit (lib.attrsets) mapAttrs recursiveUpdate;
  inherit (lib.meta) getExe getExe';

  mkEmail =
    address:
    account@{ ... }:
    let

      prompt =
        {
          title ? "Prompt",
          field ? "Password",
          hidden ? true,
          ...
        }:
        pkgs.writeShellScript "secret-prompt-${field}" ''
          ${getExe pkgs.yad} \
            --title='${title}' --separator="" \
            --form \
            --field=${field}${lib.strings.optionalString hidden ":H"}
        '';

      # allow for `meta` attribute
      config = lib.attrsets.removeAttrs account [ "meta" ];
      meta = config.meta or { };
      auth =
        recursiveUpdate
          {
            keepassxc = {
              file = "~/.secret/Passwords.kdbx";
              attribute = "Password";
            };
          }
          .${toString auth.flavor}
          (meta.authentication or { });

      passwordCommand =
        {
          keepassxc =
            prompt {
              title = "Get keepassxc ${auth.attribute} [${auth.file}:${auth.entry}}]";
              field = auth.attribute;
            }
            + ''| ${getExe' pkgs.keepassxc "keepassxc-cli"} show "${auth.file}" --attributes "${auth.attribute}" "${auth.entry}"'';
        }
        .${toString auth.flavor} or null;
    in
    recursiveUpdate {
      # sane default
      inherit address;
      userName = address;
      thunderbird = {
        enable = true;
        profiles = [ "default" ];
      };
      ${setIf "passwordCommand" (meta ? authentication)} = passwordCommand;
    } config;

  accounts = mapAttrs mkEmail {
    "mib" = {
      primary = true;
      realName = "mib";
      address = "mib@kanp.ai";
      imap = {
        host = "mail.kanp.ai";
        port = 993;
      };
      smtp = {
        host = "mail.kanp.ai";
        port = 465;
      };
    };
    "company" = {
      realName = "Kanpai";
      address = "company@kanp.ai";
      imap = {
        host = "mail.kanp.ai";
        port = 993;
      };
      smtp = {
        host = "mail.kanp.ai";
        port = 465;
      };
    };
    "root" = {
      realName = "root";
      address = "root@kanp.ai";
      imap = {
        host = "mail.kanp.ai";
        port = 993;
      };
      smtp = {
        host = "mail.kanp.ai";
        port = 465;
      };
    };
    "s245244@dtu.dk" = {
      realName = "RTS";
      flavor = "outlook.office365.com";
      thunderbird.settings = id: {
        # auth via oAuth2
        "mail.server.server_${id}.authMethod" = 10;
      };
      #meta.authentication = {
      #  flavor = "keepassxc";
      #  entry = "DTU/Microsoft";
      #};
    };
  };
in
{
  home.settings = {
    programs.thunderbird = {
      enable = true;
      profiles.default = {
        accountsOrder = [
          "mib@kanp.ai"
          "company@kanp.ai"
          "root@kanp.ai"
          "s245244@dtu.dk"
        ];
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
