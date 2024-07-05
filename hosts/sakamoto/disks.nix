{ ... }:
let
  mainDevice = "/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_4TB_S7DPNJ0X218260J";
in
{
  disko.devices = {
    disk.main = {
      device = mainDevice;
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            type = "EF02";
            size = "1M";
            priority = 0;
          };
          ESP = {
            type = "EF00";
            size = "4G";
            priority = 1;
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "noexec" ];
            };
          };
          swap = {
            size = "64G";
            content = {
              type = "swap";
              randomEncryption = true;
              resumeDevice = true;
            };
          };
          zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "data";
            };
          };
        };
      };
    };

    nodev."/" = {
      fsType = "ramfs";
      mountOptions = [
        "defaults"
        "mode=755"
      ];
    };

    zpool.data = {
      type = "zpool";
      rootFsOptions = {
        compression = "zstd";
        "com.sun:auto-snapshot" = "false";

        encryption = "aes-256-gcm";
        keylocation = "prompt";
        keyformat = "passphrase";
      };

      datasets = {
        nix = {
          type = "zfs_fs";
          options.mountpoint = "legacy";
          mountpoint = "/nix";
          mountOptions = [ "noatime" ];
        };
        persist = {
          type = "zfs_fs";
          options = {
            mountpoint = "legacy";
            "com.sun:auto-snapshot" = "true";
          };
          mountpoint = "/persist";
          mountOptions = [ "noexec" ];
          # copy over host keys
          postMountHook = ''
            mkdir --parents --mode=755 /mnt/persist/etc/ssh
            find /etc/ssh/ -type f -name "ssh_host_*_key" \
              -execdir cp {,/mnt/persist}/etc/ssh/{} \;
          '';
        };
      };
    };
  };

  fileSystems."/persist".neededForBoot = true;
}
