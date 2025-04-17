{ lib, config, ... }:
let
  inherit (lib.attrsets) filterAttrs mapAttrs' mapAttrsToList;

  hosts = {
    kanna = {
      host = "kanna.kanpai";
      sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPgiVv9HzuP6HlCvJeUYdSsMCp60/0HSlkYw7YA80lVX";
      storePublicKey = "C3JZdjcT13Kgqwnau3qX/YWxerHT9A1Canbb/iX+AXc=";

      builder = {
        systems = [ "x86_64-linux" ];
        maxJobs = 16;
        speedFactor = 64;
        supportedFeatures = [
          "big-parallel"
          "kvm"
          "nixos-test"
        ];
      };
    };

    mewo = {
      enabled = false;
      host = "mewo.kanpai";
      sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJtD5IqU+Y3RkZKxQYR5fXRugRensSihj7diYAIgxEdI";
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
      sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB/Xm/uSh6Ppy2lBtTr4ucw8mVBYWrqcDYLXmXN1XMTP";
      storePublicKey = "p09hN/DGfVxn0fvlKbaPglRLkV1RPPQHgj/prKPN31Y=";

      builder = {
        systems = [ "x86_64-linux" ];
        maxJobs = 8;
        speedFactor = 8;
        supportedFeatures = [
          "big-parallel"
          "kvm"
          "nixos-test"
        ];
      };
    };
  };

  # conditionally disable (parts of) remote workers
  enabled = filterAttrs (_: host: host.enabled or true) hosts;
  substituters = filterAttrs (_: host: host.substitute or true) enabled;
  builders = filterAttrs (_: host: host.build or true) enabled;
in
{
  nix = {
    distributedBuilds = true;
    extraOptions = "builders-use-substitutes = true";
    buildMachines = mapAttrsToList (
      _: b:
      {
        hostName = b.host;
        systems = [ ];
        protocol = "ssh";
        maxJobs = 1;
        speedFactor = 1;
        supportedFeatures = [ ];
      }
      // b.builder or { }
    ) builders;
  };

  substituters = mapAttrsToList (
    _: b:
    {
      protocol = "http";
      host = b.host;
      key = b.storePublicKey;
    }
    // b.substituter or { }
  ) substituters;

  home-manager.users.root.programs.ssh = {
    enable = true;
    matchBlocks = mapAttrs' (
      name:
      { host, ... }:
      {
        name = host;
        value = {
          user = "remote-builder";
          port = 12248;
          identitiesOnly = true;
          identityFile = config.age.secrets.remote-builder-key.path;
        };
      }
    ) builders;
  };

  services.openssh.knownHosts = mapAttrs' (
    name:
    { host, sshPublicKey, ... }:
    {
      name = host;
      value = {
        extraHostNames = [ "${name}.host.kanp.ai" ];
        publicKey = sshPublicKey;
      };
    }
  ) hosts;

  age.secrets.remote-builder-key.file = "${../../../secrets}/remotebuilder_${config.networking.hostName}";
}
