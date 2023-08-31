{ home }: {
  "Secret" = {
    id = "0hhw6-hojo4";
    devices = [ "mobai" ];
    path = "${home}/.secret";
    enable = true;
  };
  "Books" = {
    id = "6whpv-fec6p";
    devices = [ "mobai" "holger" ];
    path = "${home}/assets/books";
    enable = true;
  };
}
