{ settings, ... }: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.${settings.user.name} = {
      news.display = "silent";
      home.sessionVariables.EDITOR = settings.defaults.editor;
    };
  };
}
