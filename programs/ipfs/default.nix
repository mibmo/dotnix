{ ... }: {
  services.kubo = {
    enable = true;
    emptyRepo = true; # dont initialise repo with help files
    enableGC = true;
    startWhenNeeded = true;
    autoMount = true;

    settings = {
      Datastore.StorageMax = "10GB";
      Discovery.MDNS.Enabled = true;
    };
  };
}
