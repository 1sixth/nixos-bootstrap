{ ... }:
let
  mountOptions = [
    "compress-force=zstd"
    "noatime"
  ];
in
{
  boot.loader.grub.device = "/dev/sda";

  disko = {
    devices = {
      disk.main = {
        imageSize = "2G";
        device = "/dev/sda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02";
              priority = 1;
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
                  "@boot" = {
                    mountpoint = "/boot";
                    mountOptions = mountOptions ++ [ "subvol=/@boot" ];
                  };
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
      device = "/dev/sda2";
      fsType = "btrfs";
      options = mountOptions ++ [ "subvol=/@boot" ];
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
