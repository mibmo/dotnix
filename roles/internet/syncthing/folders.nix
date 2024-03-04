{ home }: {
  "Secret" = {
    id = "0hhw6-hojo4";
    devices = [ "mobai" "ichi" ];
    path = "${home}/.secret";
    enable = true;
  };
  "Code" = {
    id = "tcvau-dajz7";
    devices = [ "mobai" "ichi" ];
    path = "${home}/dev";
    versioning = {
      type = "staggered";
      params = {
        cleanInterval = "3600"; # every hour
        maxAge = "1209600"; # two weeks
      };
    };
    enable = true;
  };
  "Books" = {
    id = "6whpv-fec6p";
    devices = [ "mobai" "holger" ];
    path = "${home}/assets/books";
    enable = true;
  };
}
