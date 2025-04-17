{ lib, specification, ... }:
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
  home.settings.xdg = {
    mimeApps.enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    } // builtins.mapAttrs (_: path: "/home/${specification.user.name}/${path}") userDirs;
  };

  persist.user.directories = lib.attrsets.attrValues userDirs;
}
