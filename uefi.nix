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

  disko.devices = {
    disk.main = {
      imageSize = "2G";
      device = "/dev/vda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          esp = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=077" ];
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
