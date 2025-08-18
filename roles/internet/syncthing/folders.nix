{
  home,
  hosts ? { },
}:
let
  second = 1;
  minute = second * 60;
  hour = minute * 60;
  day = hour * 24;
  week = day * 7;
  month = week * 4;

  staggered =
    {
      age ? week * 2,
      clean ? hour,
    }:
    {
      type = "staggered";
      params = {
        cleanInterval = toString clean;
        maxAge = toString age;
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
    versioning = staggered { age = month * 2; };
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
  "Bad Dragons" = {
    id = "owyud-vzhpj";
    devices = [ "cheesedesk" ];
    path = "${home}/assets/bad-dragons";
    enable = true;
  };
}
