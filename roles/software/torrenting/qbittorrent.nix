{
  lib,
  pkgs,
  specification,
  ...
}:
let
  inherit (lib.attrsets) genAttrs mapAttrs;
  inherit (lib.dot) setIf;
  inherit (lib.lists) filter;

  setIfHas = set: property: setIf (set ? property) property;

  json = pkgs.formats.json { };
  ini = pkgs.formats.ini { };

  home = "/home/${specification.user.name}/";

  torrent = {
    categories = [
      "game"
      "movie"
      "series"
    ];
    /*
      # path to watched folder - all options optional
      "${home}/downloads/torrents" = {
        category = "series";
        tags = [ "mlp" ];
        # save to directory
        directory = "${home}/downloads/mlp";
        # managament mode: one of "auto" or "manual". default is auto
        mode = "auto";
        # one of: "none", "metadata", "downloaded". default is none
        stopCondition = "none";
        # start torrent after adding?
        start = true;
      };
    */
    watched = { };
  };
in
{
  home = {
    packages = with pkgs; [ qbittorrent ];
    # @TODO: refactor all this. perhaps a module system? or read it all from a json file?
    settings.home.file = {
      ".config/qBittorrent/categories.json".source = json.generate "qbittorrent-categories.json" (
        genAttrs torrent.categories (category: {
          save_path = "";
        })
      );
      ".config/qBittorrent/watched_folders.json".source =
        json.generate "qbittorrent-watched_folders.json"
          (
            mapAttrs (folder: config: {
              recursive = config.recursive or false;
              add_torrent_params =
                {
                  operating_mode = "AutoManaged";
                  use_auto_tmm =
                    rec {
                      "" = auto;
                      "auto" = true;
                      "manual" = false;
                    }
                    .${toString config.mode} or true;
                  stop_condition =
                    rec {
                      "" = none;
                      "none" = "";
                      "metadata" = "MetadataReceived";
                      "downloaded" = "FilesChecked";
                    }
                    .${toString config.stopCondition} or "None";
                  ${setIf (config ? "start") "stopped"} = !config.start;
                }
                //
                # passthru params
                genAttrs (filter (property: config ? property) [
                  "category"
                  "tags"
                ]) (property: config.${property});
            }) torrent.watched
          );
    };
  };

  persist.user = {
    files = [
      ".config/qBittorrent/qBittorrent" # general config
      ".config/qBittorrent/qBittorrent-data.conf" # stats
    ];
    directories = [
      ".local/share/qBittorrent"
    ];
  };
}
