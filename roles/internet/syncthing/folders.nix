{
  home,
  hosts ? { },
}:
let
  staggered =
    {
      days ? 14, # every two weeks
      clean ? 3600, # every hour
    }:
    {
      type = "staggered";
      params = {
        cleanInterval = toString clean;
        maxAge = toString (days * 86400);
      };
    };
in
{
  "Secret" = {
    id = "0hhw6-hojo4";
    devices = hosts.managed ++ [
      "mobai"
      "starlight"
      "trixie"
      "ichi"
    ];
    path = "${home}/.secret";
    versioning = staggered {
      days = 7 * 4 * 2; # two months
    };
    enable = true;
  };
  "Code" = {
    id = "tcvau-dajz7";
    devices = hosts.managed;
    path = "${home}/dev";
    versioning = staggered { };
    enable = true;
  };
  "Books" = {
    id = "6whpv-fec6p";
    devices = hosts.managed ++ [
      "mobai"
      "starlight"
      "trixie"
      "holger"
    ];
    path = "${home}/assets/books";
    enable = true;
  };
  "LitterBox" = {
    id = "adwbv-qpipw";
    devices = [ "holger" ];
    path = "${home}/assets/litterbox";
    enable = true;
  };
}
