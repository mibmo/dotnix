# <sub>dot</sub>nix -- nixos configuartion and dotfiles
Personal NixOS configuration.

## Installation
```
sudo nixos-rebuild switch --flake gh:mibmo/dotnix
```

### Manual configuration
Sadly not all configuration is automatic (yet).
You'll have to manually configure
- Firefox
	- Enable browser plugins
	- Set `toolkit.legacyUserProfileCustomizations.stylesheets` to true in about:config
- Lutris
	- Prefer non-system libraries
	- Set games directory (typically `$HOME/games`)
- Gnome:
	- Enable & configure extensions 
	- Set Shuzhi's text command to `.config/shuzhi.sh` and font to `TakaoPMincho Italic 16`
		- @TODO: create the .config/shuzhi.sh file using xdg in gnome file
