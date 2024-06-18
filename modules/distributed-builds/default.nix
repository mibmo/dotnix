{ lib, config, ... }:
let
  inherit (lib.attrsets) mapAttrs' mapAttrsToList;

  hosts = {
    kanna = {
      host = "kanna.kanpai";
      storePublicKey = "C3JZdjcT13Kgqwnau3qX/YWxerHT9A1Canbb/iX+AXc=";

      builder = {
        systems = [ "x86_64-linux" ];
        maxJobs = 16;
        speedFactor = 64;
        supportedFeatures = [ "big-parallel" "kvm" "nixos-test" ];
      };
    };

    mewo = {
      host = "mewo.kanpai";
      storePublicKey = "u6biJLZJ1OYyASejpGbnbs/hSi3vjmG1rV0E3yjY5Iw=";

      builder = {
        systems = [ "aarch64-linux" ];
        maxJobs = 1;
        speedFactor = 1;
        supportedFeatures = [ ];
      };
    };

    muffin = {
      host = "muffin.kanpai";
      storePublicKey = "p09hN/DGfVxn0fvlKbaPglRLkV1RPPQHgj/prKPN31Y=";

      builder = {
        systems = [ "x86_64-linux" ];
        maxJobs = 8;
        speedFactor = 8;
        supportedFeatures = [ "big-parallel" "kvm" "nixos-test" ];
      };
    };
  };
in
{
  nix = {
    distributedBuilds = true;
    extraOptions = "builders-use-substitutes = true";
    buildMachines = mapAttrsToList
      (_: b: {
        hostName = b.host;
        systems = [ ];
        protocol = "ssh";
        maxJobs = 1;
        speedFactor = 1;
        supportedFeatures = [ ];
      } // b.builder or { })
      hosts;
  };

  substituters = mapAttrsToList
    (_: b: {
      protocol = "http";
      host = b.host;
      key = b.storePublicKey;
    } // b.substituter or { })
    hosts;

  home-manager.users.root.programs.ssh = {
    enable = true;
    matchBlocks = mapAttrs'
      (name: { host, ... }: {
        name = host;
        value = {
          user = "remote-builder";
          port = 12248;
          identitiesOnly = true;
          identityFile = config.age.secrets.remote-builder-key.path;
        };
      })
      hosts;
  };

  age.secrets.remote-builder-key.file = "${../../secrets}/remotebuilder_${config.networking.hostName}";
}
