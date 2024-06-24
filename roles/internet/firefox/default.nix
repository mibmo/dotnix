{ lib, pkgs, config, ... }:
let
  extensions = with config.nur.repos.rycee.firefox-addons; [
    tokyo-night-v2 # theme
    sidebery # nested tabs
    floccus # blookmark sync

    # privacy
    ublock-origin # ad block
    umatrix # fine-grained resource blocking
    decentraleyes # cache common web dependencies such as ajax
    clearurls
    consent-o-matic # handle gdpr consent forms
    libredirect # redirect big sites to privacy-friendly alternatives

    # misc
    keepassxc-browser
    unpaywall # (legally) remove paywalls from journal websites
    flagfox # display country info about website host
  ];

  search = {
    force = true;
    default = "DuckDuckGo";
    engines =
      let
        second = 1000;
        minute = 60 * second;
        hour = 60 * minute;
        day = 24 * hour;
        week = 7 * day;
      in
      {
        # nix
        "NixOS Wiki" = {
          urls = [{ template = "https://nixos.wiki/index.php?search={searchTerms}"; }];
          iconUpdateURL = "https://nixos.wiki/favicon.png";
          updateInterval = week;
          definedAliases = [ "@nw" "@nixwiki" ];
        };

        "Nix Reference Manual" = {
          urls = [{ template = "https://nixos.org/manual/nix/unstable/?search={searchTerms}"; }];
          iconUpdateURL = "https://nixos.org/manual/nix/unstable/favicon.png";
          updateInterval = week;
          definedAliases = [ "@nm" "@nixman" "@nixmanual" ];
        };

        "Nix Packages" = {
          urls = [{
            template = "https://search.nixos.org/packages";
            params = [
              { name = "type"; value = "packages"; }
              { name = "query"; value = "{searchTerms}"; }
            ];
          }];

          icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          definedAliases = [ "@np" "@nixpkgs" ];
        };

        "Nix Options" = {
          urls = [{
            template = "https://search.nixos.org/options";
            params = [
              { name = "type"; value = "packages"; }
              { name = "query"; value = "{searchTerms}"; }
            ];
          }];

          icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          definedAliases = [ "@no" "@nixopts" ];
        };

        "Home Manager Options" = {
          urls = [{ template = "https://home-manager-options.extranix.com/?query={searchTerms}"; }];
          iconUpdateURL = "https://home-manager-options.extranix.com/images/favicon.ico";
          updateInterval = week;
          definedAliases = [ "@hm" "@hmopts" ];
        };

        # rust
        "Rust Language Documentation" = {
          urls = [{ template = "https://doc.rust-lang.org/std/?search={searchTerms}"; }];
          iconUpdateURL = "https://doc.rust-lang.org/favicon.ico";
          updateInterval = week;
          definedAliases = [ "@r" "@rust" ];
        };

        "Rust Crates Documentation" = {
          urls = [{ template = "https://docs.rs/releases/search?query={searchTerms}"; }];
          iconUpdateURL = "https://docs.rs/favicon.ico";
          updateInterval = week;
          definedAliases = [ "@drs" "@docsrs" ];
        };

        "Lib.rs" = {
          urls = [{ template = "https://lib.rs/search?q={searchTerms}"; }];
          iconUpdateURL = "https://lib.rs/favicon.ico";
          updateInterval = week;
          definedAliases = [ "@lrs" "@librs" ];
        };

        # gaming
        "Terraria Wiki" = {
          urls = [{ template = "https://terraria.wiki.gg/index.php?search={searchTerms}"; }];
          iconUpdateUrl = "https://terraria.wiki.gg/favicon.ico";
          updateInterval = week;
          definedAliases = [ "@tw" "@terraria" ];
        };

        # dictionaries
        "Jisho" = {
          urls = [{ template = "https://jisho.org/search/{searchTerms}"; }];
          iconUpdateURL = "https://assets.jisho.org/assets/favicon-062c4a0240e1e6d72c38aa524742c2d558ee6234497d91dd6b75a182ea823d65.ico";
          updateInterval = week;
          definedAliases = [ "@js" "@jisho" ];
        };
      };
  };

  settings = {
    "app.normandy.first_run" = false;
    "app.shield.optoutstudies.enabled" = false;

    "browser.contentblocking.category" = "strict";
    "browser.download.useDownloadDir" = false;

    "browser.tabs.loadInBackground" = true;

    # theme
    "extensions.activeThemeID" = "firefox-alpenglow@mozilla.org";
    "extensions.extensions.activeThemeID" = "firefox-alpenglow@mozilla.org";

    # extensions
    "extensions.update.enabled" = false;
    "extensions.webcompat.enable_picture_in_picture_overrides" = true;
    "extensions.webcompat.enable_shims" = true;
    "extensions.webcompat.perform_injections" = true;
    "extensions.webcompat.perform_ua_overrides" = true;

    # privacy 
    "privacy.donottrackheader.enabled" = true;
  };
in
{
  home.settings.programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    profiles.default = {
      inherit extensions search settings;
      userChrome = builtins.readFile ./userChrome.css;
    };
  };

  persist.user =
    let
      perProfile = profile: map (path: ".mozilla/firefox/${profile}/${path}");
      prefix = prefix: map (suffix: prefix + suffix);
      sqlite = file: prefix file [
        ".sqlite"
        ".sqlite-shm"
        ".sqlite-wal"
      ];
    in
    lib.attrsets.mapAttrs
      (_: paths: perProfile "default" (lib.lists.flatten paths))
      {
        directories = [
          "crashes"
          "storage"
        ];
        files = [
          [
            "cert9.db"
            "compatability.ini"
          ]
          (sqlite "content-prefs")
          (sqlite "cookies")
          (sqlite "favicons")
          (sqlite "formhistory")
          (sqlite "permissions")
          (sqlite "places")
          (sqlite "protections")
          (sqlite "storage")
          (sqlite "storage-sync-v2")
          (sqlite "webappsstore")
        ];
      };
}
