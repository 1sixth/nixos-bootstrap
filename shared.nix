{ modulesPath, pkgs, ... }:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot = {
    # https://github.com/nix-community/preservation/pull/23
    initrd.systemd.tmpfiles.settings.preservation."/sysroot/persistent/preservation/etc/machine-id".f.argument =
      "uninitialized";
    kernel.sysctl = {
      # https://github.com/torvalds/linux/blob/218af599fa635b107cfe10acf3249c4dfe5e4123/net/ipv4/tcp_bbr.c#L55
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  networking = {
    firewall.enable = false;
    hostName = "bootstrap";
    useDHCP = false;
    useNetworkd = true;
  };

  nix.settings = {
    substituters = [ "https://cache.garnix.io" ];
    trusted-public-keys = [ "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" ];
  };

  preservation = {
    enable = true;
    preserveAt."/persistent/preservation" = {
      directories = [
        "/root"
        "/var/cache"
        "/var/log/journal"
        {
          directory = "/var/lib";
          inInitrd = true;
        }
      ];
      files = [
        {
          file = "/etc/machine-id";
          inInitrd = true;
        }
      ];
    };
  };

  services.openssh = {
    enable = true;
    hostKeys = [
      {
        path = "/persistent/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
    settings.PermitRootLogin = "yes";
  };

  systemd = {
    network.networks.default = {
      DHCP = "yes";
      matchConfig.Type = "ether";
    };
    # https://github.com/nix-community/preservation/pull/23
    services.systemd-machine-id-commit.unitConfig.ConditionFirstBoot = true;
  };

  system.stateVersion = "24.11";

  time.timeZone = "Asia/Shanghai";

  users.users.root.initialPassword = "hunter2";
}
