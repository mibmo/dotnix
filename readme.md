# <sub>dot</sub>nix -- nixos configuartion and dotfiles
Personal NixOS configuration. Not intended for outside consumption, but I won't stop you.

## Hosts
Directory for each nixos configuration exposed, handling partitioning, booting, and host-specific quirks.

## Modules
The modules directory contains NixOS modules that either map from one option to another (i.e. `home.` to `home-manager.users.${settings.user.name}`), expose new options (i.e. substituters) or expand upon existing modules (i.e. impermanence).
They're imported for all hosts, regardless of other setup.

## Roles
Roles define larger chunks of configuration exposing enabling specific tasks or functionality.
They're not necessarily universal, so they're applied on a per-host basis (see config.nix).
