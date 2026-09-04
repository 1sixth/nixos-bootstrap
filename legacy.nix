{ ... }:
let
  mountOptions = [
    "compress-force=zstd"
    "noatime"
  ];
in
{
  disko.devices = {
    disk.main = {
      imageSize = "2G";
      device = "/dev/vda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            size = "1M";
            type = "EF02";
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
                  inherit mountOptions;
                  mountpoint = "/boot";
                };
                "@nix" = {
                  inherit mountOptions;
                  mountpoint = "/nix";
                };
                "@persistent" = {
                  inherit mountOptions;
                  mountpoint = "/persistent";
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

  fileSystems."/persistent".neededForBoot = true;
}
