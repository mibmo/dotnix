{ pkgs, config, settings, ... }: {
  home-manager.users.${settings.user.name}.home.packages = [ pkgs.ydotool ];

  environment.variables.YDOTOOL_SOCKET = "/run/ydotool.socket";

  systemd.services.ydotoold = {
    description = "An auto-input utility for wayland";
    documentation = [ "man:ydotool(1)" "man:ydotoold(8)" ];
    wantedBy = ["multi-user.target"];
    
    serviceConfig.ExecStart = ''
      ${pkgs.ydotool}/bin/ydotoold \
        --socket-path=${config.environment.variables.YDOTOOL_SOCKET} \
        --socket-own=0:1 \
        --socket-perm=0660
    '';
  };
}
