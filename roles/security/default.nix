{ inputs, pkgs, config, host, ... }: {
  home = {
    packages = with pkgs; [
      keepassxc
      age
      minisign
      nitrokey-app
      # broken on unstable 2024-03-04
      #pynitrokey
      monero-gui
      inputs.agenix.packages.${host.system}.default
    ];
    groups = [ "nitrokey" ];
    settings = {
      programs = {
        gpg = {
          enable = true;
          scdaemonSettings.disable-ccid = true;
        };
      };
      services.gpg-agent = {
        enable = true;
        enableExtraSocket = true;
        enableSshSupport = true;
        enableScDaemon = true;
        pinentryFlavor = config.programs.gnupg.agent.pinentryFlavor;
      };
    };
  };

  services.udev.packages = [ pkgs.nitrokey-udev-rules ];

  age = {
    identityPaths = map (key: key.path) config.services.openssh.hostKeys ++ [ (config.users.users.mib.home + "/.secret/age.keys") ];
    secrets = builtins.mapAttrs
      (name: value: { file = ../../secrets/${name}; })
      (import ../../secrets/secrets.nix);
  };

  environment.shellInit = ''
    export SSH_AUTH_SOCK=$(${pkgs.gnupg}/bin/gpgconf --list-dirs agent-ssh-socket)
  '';

  hardware.gpgSmartcards.enable = true;
  hardware.nitrokey.enable = true;
  services.pcscd.enable = true;
  programs.ssh.startAgent = false;
}
