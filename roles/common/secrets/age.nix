{
  inputs,
  config,
  host,
  ...
}:
{
  # @TODO: use openssh hostKeys
  age.identityPaths = [
    "/etc/ssh/ssh_host_ed25519_key"
    "/etc/ssh/ssh_host_rsa_key"
    "/persist/etc/ssh/ssh_host_ed25519_key"
    "/persist/etc/ssh/ssh_host_rsa_key"
  ];

  home.packages = [ inputs.agenix.packages.${host.system}.default ];

  persist.files = map (key: key.path) config.services.openssh.hostKeys;
}
