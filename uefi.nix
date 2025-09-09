{ ... }:
let
  mountOptions = [
    "compress-force=zstd"
    "noatime"
  ];
in
{
  boot.loader = {
    grub.enable = false;
    systemd-boot.enable = true;
  };

  disko = {
    devices = {
      disk.main = {
        imageSize = "2G";
        device = "/dev/sda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            esp = {
              size = "512M";
              type = "EF00";
              priority = 1;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [
                  "--checksum"
                  "xxhash"
                ];
                subvolumes = {
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = mountOptions ++ [ "subvol=/@nix" ];
                  };
                  "@persistent" = {
                    mountpoint = "/persistent";
                    mountOptions = mountOptions ++ [ "subvol=/@persistent" ];
                  };
                };
              };
            };
          };
        };
      };
      nodev."/" = {
        fsType = "tmpfs";
        mountOptions = [ "mode=755" ];
      };
    };
    enableConfig = false;
  };

  fileSystems = {
    "/" = {
      fsType = "tmpfs";
      options = [ "mode=755" ];
    };
    "/boot" = {
      device = "/dev/sda1";
      fsType = "vfat";
      options = [ "umask=0077" ];
    };
    "/nix" = {
      device = "/dev/sda2";
      fsType = "btrfs";
      options = mountOptions ++ [ "subvol=/@nix" ];
    };
    "/persistent" = {
      device = "/dev/sda2";
      fsType = "btrfs";
      neededForBoot = true;
      options = mountOptions ++ [ "subvol=/@persistent" ];
    };
  };
}
