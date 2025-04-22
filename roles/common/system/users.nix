{ config, specification, ... }:
{
  users = {
    mutableUsers = false;
    users.${specification.user.name} = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "input"
        "systemd-journal"
      ];
      hashedPasswordFile = config.age.secrets.user_password.path;
    };
  };
}
