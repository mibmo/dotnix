{ lib, ... }: {
  specialisation =
    let
      inherit (lib.attrsets) mapAttrs recursiveUpdate;
      inherit (lib.lists) flatten foldl toList;

      disable-gpu = {
        services.xserver.videoDrivers = lib.mkForce [
          "modesetting"
          "fbdev"
        ];
        hardware.nvidia = lib.mkForce {
          modesetting.enable = false;
          prime.offload.enable = false;
          powerManagement.enable = false;
        };
      };
      disable-gui = [
        disable-gpu
        {
          services.xserver.enable = lib.mkForce false;
          boot.plymouth.enable = lib.mkForce false;
        }
      ];
    in
    mapAttrs
      (_: specialisation: specialisation // {
        configuration = foldl recursiveUpdate { } (flatten (toList specialisation.configuration));
      })
      {
        no-gpu.configuration = disable-gpu;
        no-gui.configuration = disable-gui;
      };
}
