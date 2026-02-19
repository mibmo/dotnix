{ ... }:
{
  home.settings.services.nextcloud-client = {
    enable = false;
    startInBackground = true;
  };

  persist.user.directories = [
    ".config/Nextcloud"
  ];
}
