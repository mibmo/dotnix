{
  pkgs,
  config,
  ...
}:
let
  # post-quantum openssh kex exchange algorithms
  sshPQKex = [
    "sntrup761x25519-sha512"
    "sntrup761x25519-sha512@openssh.com"
    "mlkem768x25519-sha256"
  ];
in
{
  home = {
    packages = with pkgs; [
      age
      keepassxc
      minisign
      nitrokey-app
      # broken on unstable 2024-03-04
      #pynitrokey
    ];
    groups = [ "nitrokey" ];
    settings = {
      programs = {
        gpg = {
          enable = true;
          scdaemonSettings.disable-ccid = true;
        };
        ssh.matchBlocks."*".kexAlgorithms = sshPQKex;
      };
      services.gpg-agent = {
        enable = true;
        enableExtraSocket = true;
        enableSshSupport = true;
        enableScDaemon = true;
        pinentry.package = config.programs.gnupg.agent.pinentryPackage;
      };
    };
  };

  security.apparmor.enable = true;

  age = {
    identityPaths = map (key: key.path) config.services.openssh.hostKeys;
    secrets = builtins.mapAttrs (name: value: {
      file = ../../../secrets/${name};
    }) (import ../../../secrets/secrets.nix);
  };

  environment.shellInit = ''
    export SSH_AUTH_SOCK=$(${pkgs.gnupg}/bin/gpgconf --list-dirs agent-ssh-socket)
  '';

  hardware.gpgSmartcards.enable = true;
  hardware.nitrokey.enable = true;
  services.pcscd.enable = true;
  programs.ssh = {
    startAgent = false;
    kexAlgorithms = sshPQKex;
  };

  persist.user = {
    directories = [
      {
        directory = ".gnupg";
        mode = "0700";
      }
    ];
    files = [ ".cache/keepassxc/keepassxc.ini" ];
  };
}
