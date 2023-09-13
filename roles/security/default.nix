{ inputs, pkgs, config, settings, host, ... }:
let
  module = {
    programs.gpg.enable = true;
  };
in
{
  home-manager.users.${settings.user.name} = {
    imports = [ module ];
    home.packages = with pkgs; [
      keepassxc
      age
      minisign
      nitrokey-app
      (pynitrokey.overrideAttrs (final: {
        propagatedBuildInputs = final.propagatedBuildInputs ++ [ pkgs.python310Packages.importlib-metadata ];
      }))
      monero-gui
      inputs.agenix.packages.${host.system}.default
    ];
  };

  users = {
    users.${settings.user.name}.extraGroups = [ "nitrokey" ];
    groups.nitrokey = { };
  };

  services.udev.packages = [ pkgs.nitrokey-udev-rules ];

  age = {
    identityPaths = [ (config.users.users.mib.home + "/.secret/age.keys") ];
    secrets = builtins.mapAttrs
      (name: value: { file = ../../secrets/${name}; })
      (import ../../secrets/secrets.nix);
  };

  hardware.gpgSmartcards.enable = true;
  hardware.nitrokey.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.pcscd.enable = true;
}
