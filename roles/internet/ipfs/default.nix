{ ... }: {
  services.kubo = {
    enable = false;
    enableGC = true;
    localDiscovery = true;
    autoMigrate = true;
    autoMount = true;
    settings = {
      Datastore.StorageMax = "10GB";
      Discovey.MDNS.Enabled = true;
    };
  };
}
