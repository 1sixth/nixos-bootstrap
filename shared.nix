{ modulesPath, pkgs, ... }:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot = {
    initrd.systemd.enable = true;
    kernel.sysctl = {
      # https://github.com/torvalds/linux/blob/218af599fa635b107cfe10acf3249c4dfe5e4123/net/ipv4/tcp_bbr.c#L55
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  environment.persistence."/persistent/impermanence" = {
    directories = [
      "/root"
      "/tmp"
      "/var/lib"
      "/var/log/journal"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];
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

  services.openssh = {
    enable = true;
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  systemd.network.networks.default = {
    DHCP = "yes";
    matchConfig.Type = "ether";
  };

  system.stateVersion = "24.11";

  time.timeZone = "Asia/Shanghai";

  users.users.root.initialPassword = "hunter2";
}
