{ modulesPath, pkgs, ... }:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot = {
    initrd.systemd.enable = true;
    kernel.sysctl = {
      # https://github.com/torvalds/linux/blob/218af599fa635b107cfe10acf3249c4dfe5e4123/net/ipv4/tcp_bbr.c#L55
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
      # https://github.com/quic-go/quic-go/wiki/UDP-Buffer-Sizes#non-bsd
      "net.core.rmem_max" = 7500000;
      "net.core.wmem_max" = 7500000;
    };
    kernelParams = [ "zswap.enabled=1" ];
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

  users.users.root = {
    initialPassword = "hunter2";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAHOSqODpw3my6PkhWrAD/sulDNCiNjKqLjNOtFPMFwr" # Normal ssh-ed25519 Key
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIFo0aSRnBTZxloY4B3UBOtuRJVEKjs5qgjKerAB2sSr7AAAABHNzaDo=" # ed25519-sk Resident Key
    ];
  };

}
