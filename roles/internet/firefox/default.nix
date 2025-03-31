{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.attrsets) genAttrs mapAttrs';
  inherit (lib.strings) concatStringsSep;

  firefox-addons = pkgs.nur.repos.rycee.firefox-addons;

  extensions = {
    # clean tracking off urls
    clearurls = { };
    # handle gdpr consent forms
    consent-o-matic = { };
    # clickbait-less youtube
    dearrow.licenseKey = "F4tZs-cb353";
    # cache common web dependencies such as ajax
    decentraleyes = { };
    # display info about website host
    flagfox = { };
    # bookmark sync
    floccus = { };
    # password manager
    keepassxc-browser = { };
    # redirect big sites to privacy-friendly alternatives
    #libredirect = { };
    # estimates youtube dislikes
    return-youtube-dislikes = { };
    # side-menu nested tabs = {};
    sidebery = { };
    # manage and switch between proxies
    smartproxy = { };
    # skip annoying youtube segments
    sponsorblock = { };
    # adds summaries of terms of services
    terms-of-service-didnt-read = { };
    # performant ad- & tracker-blocking
    ublock-origin.adminSettings =
      let
        builtinLists = [
          "JPN-0" # Japanese ad-blocking
          "KOR-0" # Korean ad-blocking
          "NOR-0" # Dandelion Sprout's nordic-relevant filters
          "adguard-generic" # AdGuard - Ads (ads)
          "adguard-spyware" # AdGuard - Spyware (privacy)
          "block-lan" # Block outsider intrusion into LAN (privacy)
          "curben-phishing" # Phishing URLs (security)
          "dpollock-0" # Dan Pollock's hosts file (multipurpose)
          "easylist" # EasyList (ads)
          "easyprivacy" # EasyPrivacy (privacy)
          "plowe-0" # Pete Lowe's Ad and tracking server list (multipurpose)
          "ublock-annoyances" # uBlock - Annoyances
          "ublock-badware" # uBlock - Badware risks
          "ublock-filters" # uBlock - Ads
          "ublock-privacy" # uBlock - Privacy
          "ublock-quick-fixes" # uBlock - Quick fixes
          "ublock-unbreak" # uBlock - Unbreak
          "urlhaus-1" # Online Malicious URLs (security)
        ];
        extraLists = [
          "https://github.com/DandelionSprout/adfilt/raw/master/LegitimateURLShortener.txt" # sanitize urls
        ];
      in
      {
        userSettings = {
          uiTheme = "auto";
          importedLists = extraLists;
          externalLists = concatStringsSep "\n" extraLists;
        };
        selectedFilterLists = builtinLists ++ extraLists;
      };
    # remove paywalls for journals
    unpaywall = { };
  };

  policies = {
    AutofillAddressEnabled = true; # autofill address
    AutofillCreditCardEnabled = false; # dont autofill credit cards
    DisableFirefoxStudies = true; # disable firefox studies
    DisableSetDesktopBackground = true; # remove "set as desktop background" menu item when right-clicking
    DisablePocket = true; # disable firefox pocket
    DisableTelemetry = true; # disable mozilla telemetry
    DontCheckDefaultBrowser = true; # assume firefox is default
    OfferToSaveLogins = false; # managed by password manager
    ExtensionUpdate = false; # managed by nix
    ExtensionSettings =
      # enable configured extensions
      mapAttrs' (
        name: _:
        let
          addon = firefox-addons.${name};
          inherit (addon) addonId;
        in
        {
          name = addonId;
          value = {
            installation_mode = "force_installed";
            install_url = "file:///${addon}/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/${addonId}.xpi";
          };
        }
      ) extensions
      # disallow manual management of extensions
      // {
        "*" = {
          installation_mode = "blocked";
          blocked_install_message = "Manual addon management is disabled";
        };
      };
    "3rdparty".Extensions = mapAttrs' (name: config: {
      name = firefox-addons.${name}.addonId;
      value = config;
    }) extensions;
  };

  containers = {
    entertainment = {
      id = 0;
      icon = "fence";
      color = "blue";
    };
    hobby = {
      id = 1;
      icon = "circle";
      color = "purple";
    };
    shopping = {
      id = 2;
      icon = "cart";
      color = "orange";
    };
    personal = {
      id = 3;
      icon = "fingerprint";
      color = "pink";
    };
    dangerous = {
      id = 4;
      icon = "fence";
      color = "red";
    };
  };

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
        # traditional
        "Bing".metaData = {
          alias = "@b";
          hidden = true;
        };
        "Google".metaData = {
          alias = "@g";
          hidden = true;
        };

        # nix
        "NixOS Wiki" = {
          urls = [ { template = "https://wiki.nixos.org/w/index.php?search={searchTerms}"; } ];
          iconUpdateURL = "https://wiki.nixos.org/nixos.png";
          updateInterval = week;
          definedAliases = [
            "@nw"
            "@nixwiki"
          ];
        };

        "Nix Reference Manual" = {
          urls = [ { template = "https://nixos.org/manual/nix/unstable/?search={searchTerms}"; } ];
          iconUpdateURL = "https://nixos.org/manual/nix/unstable/favicon.png";
          updateInterval = week;
          definedAliases = [
            "@nm"
            "@nixman"
            "@nixmanual"
          ];
        };

        "Nix Packages" = {
          urls = [
            {
              template = "https://search.nixos.org/packages";
              params = [
                {
                  name = "type";
                  value = "packages";
                }
                {
                  name = "query";
                  value = "{searchTerms}";
                }
              ];
            }
          ];

          icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          definedAliases = [
            "@np"
            "@nixpkgs"
          ];
        };

        "Nix Options" = {
          urls = [
            {
              template = "https://search.nixos.org/options";
              params = [
                {
                  name = "type";
                  value = "packages";
                }
                {
                  name = "query";
                  value = "{searchTerms}";
                }
              ];
            }
          ];

          icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          definedAliases = [
            "@no"
            "@nixopts"
          ];
        };

        "Home Manager Options" = {
          urls = [ { template = "https://home-manager-options.extranix.com/?query={searchTerms}"; } ];
          iconUpdateURL = "https://home-manager-options.extranix.com/images/favicon.ico";
          updateInterval = week;
          definedAliases = [
            "@hm"
            "@hmopts"
          ];
        };

        # rust
        "Rust Language Documentation" = {
          urls = [ { template = "https://doc.rust-lang.org/std/?search={searchTerms}"; } ];
          iconUpdateURL = "https://doc.rust-lang.org/favicon.ico";
          updateInterval = week;
          definedAliases = [
            "@r"
            "@rust"
          ];
        };

        "Rust Crates Documentation" = {
          urls = [ { template = "https://docs.rs/releases/search?query={searchTerms}"; } ];
          iconUpdateURL = "https://docs.rs/favicon.ico";
          updateInterval = week;
          definedAliases = [
            "@drs"
            "@docsrs"
          ];
        };

        "Lib.rs" = {
          urls = [ { template = "https://lib.rs/search?q={searchTerms}"; } ];
          iconUpdateURL = "https://lib.rs/favicon.ico";
          updateInterval = week;
          definedAliases = [
            "@lrs"
            "@librs"
          ];
        };

        # gaming
        "Terraria Wiki" = {
          urls = [ { template = "https://terraria.wiki.gg/index.php?search={searchTerms}"; } ];
          iconUpdateUrl = "https://terraria.wiki.gg/favicon.ico";
          updateInterval = week;
          definedAliases = [
            "@tw"
            "@terraria"
          ];
        };

        # dictionaries
        "Jisho" = {
          urls = [ { template = "https://jisho.org/search/{searchTerms}"; } ];
          iconUpdateURL = "https://assets.jisho.org/assets/favicon-062c4a0240e1e6d72c38aa524742c2d558ee6234497d91dd6b75a182ea823d65.ico";
          updateInterval = week;
          definedAliases = [
            "@js"
            "@jisho"
          ];
        };
      };
  };

  settings = {
    "app.normandy.first_run" = false;
    "trailhead.firstrun.didSeeAboutWelcome" = true;

    "browser.download.useDownloadDir" = false;

    "browser.tabs.loadInBackground" = true;

    # enable user chrome
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

    # extensions
    "extensions.autoDisableScopes" = 0;
    "extensions.update.enabled" = false;
    "extensions.webcompat.enable_picture_in_picture_overrides" = true;
    "extensions.webcompat.enable_shims" = true;
    "extensions.webcompat.perform_injections" = true;
    "extensions.webcompat.perform_ua_overrides" = true;

    # privacy 
    "app.shield.optoutstudies.enabled" = false;
    "browser.contentblocking.category" = "strict";
    "privacy.donottrackheader.enabled" = true;
  };
in
{
  home.settings = {
    programs.firefox = {
      enable = true;
      package = pkgs.firefox;
      inherit policies;
      profiles.default = {
        isDefault = true;
        inherit containers search settings;
        userChrome = builtins.readFile ./userChrome.css;
        containersForce = true;
      };
    };
    xdg.mimeApps.defaultApplications = genAttrs [
      "text/html"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
    ] (_: "firefox.desktop");
  };

  persist.user =
    let
      perProfile = profile: map (path: ".mozilla/firefox/${profile}/${path}");
      prefix = prefix: map (suffix: prefix + suffix);
      sqlite =
        file:
        prefix file [
          ".sqlite"
          ".sqlite-shm"
          ".sqlite-wal"
        ];
    in
    lib.attrsets.mapAttrs (_: paths: perProfile "default" (lib.lists.flatten paths)) {
      directories = [
        # website local storage
        "storage"
      ];
      files = [
        # mitigate bounce tracking protection.
        # should generally not be persisted
        #(sqlite "bounce-tracking-protection")

        # website preferences; media permissions, font preferences, accessibility, etc
        #(sqlite "content-prefs")

        # website cookies
        (sqlite "cookies")

        # favicon cache and metadata
        (sqlite "facicons")

        # web form history; logins, credentials, usernames, etc
        #(sqlite "formhistory")

        # permissions for specific websites; allowing pop-ups, location access, camera/mic, etc
        #(sqlite "permissions")

        # bookmarks, browsing history, and other metadata
        (sqlite "places")

        # tracking protection information; blocked websites, block history, etc
        (sqlite "protections")

        # firefox sync data
        #(sqlite "storage-sync-v2")

        # website local storage
        (sqlite "storage")

        # extensions data, e.g. icons and manifests.
        # may not need to persist when configuring via policy
        #(sqlite "webappsstore")
      ];
    };
}
