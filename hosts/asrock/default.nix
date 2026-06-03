{den, ...}: {
  den.hosts.x86_64-linux.asrock = {
    hostName = "asrock";
    nix-config-path = "/home/jaden/Projects/nix-config-change";
    users = {
      admin = {};
      jaden = {};
    };
    disk-layout = {
      disk0 = "/dev/nvme0n1";
      disk1 = "/dev/nvme1n1";
      enableSwap = true;
      swapSize = 4096;
      enableDiscards = true;
    };
  };
  den.aspects.asrock = {
    includes = with den.aspects; [
      disk-layout._.btrfs-on-luks-with-raid0
      pc
      pc._.plasma
      devops
      gaming
    ];
    nixos = {
      hardware.facter.reportPath = ./facter.json;
      boot.binfmt.emulatedSystems = ["aarch64-linux"];

      services.usbguard.enable = false;

      programs.gamemode.settings = {
        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          gpu_device = 1;
          amd_performance_level = "auto";
        };
      };
    };
    homeManager = {
      programs.ssh.settings = {
        aesop.hostname = "192.168.1.213";
        dokja.hostname = "66.179.137.242";
        teemo.hostname = "192.168.1.3";
      };
    };
    provides.to-users.homeManager = {pkgs, ...}: {
      home.packages = [pkgs.ente-desktop];
    };
  };
}
