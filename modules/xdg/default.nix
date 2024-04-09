{ lib, settings, ... }:
let
  userDirs = {
    desktop = ".desktop";
    documents = "assets/documents";
    download = "downloads";
    music = "assets/music";
    pictures = "assets/images";
    videos = "assets/videos";
    templates = ".templates";
    publicShare = ".share";
  };
in
{
  home.settings.xdg.userDirs = {
    enable = true;
    createDirectories = true;
  } // builtins.mapAttrs
    (_: path: "/home/${settings.user.name}/${path}")
    userDirs;

  environment.persistence.main.users.${settings.user.name}.directories = lib.attrsets.attrValues userDirs;
}
