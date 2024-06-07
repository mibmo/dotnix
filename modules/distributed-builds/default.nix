{ lib, config, ... }:
{
  nix = {
    distributedBuilds = true;
    extraOptions = "builders-use-substitutes = true";
    buildMachines = [
      {
        hostName = "kanna.kanpai";
        systems = [ "x86_64-linux" ];
        protocol = "ssh";
        maxJobs = 16;
        speedFactor = 64;
        supportedFeatures = [ "big-parallel" "kvm" "nixos-test" ];
      }
      {
        hostName = "mewo.kanpai";
        systems = [ "aarch64-linux" ];
        protocol = "ssh";
        maxJobs = 1;
        speedFactor = 1;
        supportedFeatures = [ ];
      }
      {
        hostName = "muffin.kanpai";
        systems = [ "x86_64-linux" ];
        protocol = "ssh";
        maxJobs = 8;
        speedFactor = 8;
        supportedFeatures = [ "big-parallel" "kvm" "nixos-test" ];
      }
    ];
  };

  substituters = [
    "kanna.kanpai:C3JZdjcT13Kgqwnau3qX/YWxerHT9A1Canbb/iX+AXc="
    "mewo.kanpai:u6biJLZJ1OYyASejpGbnbs/hSi3vjmG1rV0E3yjY5Iw="
    "muffin.kanpai:p09hN/DGfVxn0fvlKbaPglRLkV1RPPQHgj/prKPN31Y="
  ];

  home-manager.users.root.programs.ssh = {
    enable = true;
    matchBlocks =
      lib.genAttrs (map (m: m.hostName) config.nix.buildMachines) (host: {
        user = "remote-builder";
        port = 12248;
        identitiesOnly = true;
        identityFile = config.age.secrets.remote-builder-key.path;
      });
  };

  age.secrets.remote-builder-key.file = "${../../secrets}/remotebuilder_${config.networking.hostName}";
}
