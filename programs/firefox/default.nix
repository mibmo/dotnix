{ pkgs, ... }:

let
  searchEngine = "DuckDuckGo";

  extensions = with pkgs.nur.repos.rycee.firefox-addons; [
    tokyo-night-v2 # theme
    sidebery
    umatrix
    unpaywall
  ];

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

  profile = {
    inherit extensions settings;
    search.force = true;
    userChrome = builtins.readFile ./userChrome.css;

    search.default = searchEngine;
    search.engines = {
      "NixOS Wiki" = {
        urls = [{ template = "https://nixos.wiki/index.php?search={searchTerms}"; }];
        iconUpdateURL = "https://nixos.wiki/favicon.png";
        updateInterval = 24 * 60 * 60 * 1000; # every day
        definedAliases = [ "@nw" "@nixwiki" ];
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
        urls = [{ template = "https://mipmip.github.io/home-manager-option-search/?{searchTerms}"; }];
        iconUpdateURL = "https://mipmip.github.io/home-manager-option-search/images/favicon.png";
        updateInterval = 24 * 60 * 60 * 1000; # every day
        definedAliases = [ "@hm" "@hmopts" ];
      };

    };
  };
in
{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    profiles.default = profile;
  };
}
