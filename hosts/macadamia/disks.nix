{ ... }: {
  disko.devices = {
    disk.main = {
      device = "/dev/disk/by-id/nvme-APPLE_SSD_AP0128J_C08730604DVHV4KA9";
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
            size = "1G";
            priority = 1;
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "noexec" ];
            };
          };
          swap = {
            size = "16G";
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
        "noexec"
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
          options.mountpoint = "legacy";
          mountpoint = "/persist";
          mountOptions = [ "noexec" ];
          postMountHook = ''
            # copy over host keys
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
