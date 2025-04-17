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
    "company@kanp.ai" = {
      realName = "Kanpai";
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
        "mail.smtpserver.smtp_${id}.authMethod" = 10;
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
