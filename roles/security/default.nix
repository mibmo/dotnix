{ inputs, pkgs, config, ... }: {
  home = {
    packages = with pkgs; [
      age
      keepassxc
      minisign
      monero-gui
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
      };
      services.gpg-agent = {
        enable = true;
        enableExtraSocket = true;
        enableSshSupport = true;
        enableScDaemon = true;
        pinentryPackage = config.programs.gnupg.agent.pinentryPackage;
      };
    };
  };

  age = {
    identityPaths = map (key: key.path) config.services.openssh.hostKeys;
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

  persist.user.files = [ ".cache/keepassxc/keepassxc.ini" ];
}
