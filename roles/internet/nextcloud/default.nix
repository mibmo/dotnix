{ ... }:
{
  home.settings.services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };

  persist.user.directories = [
    ".config/Nextcloud"
  ];
}
