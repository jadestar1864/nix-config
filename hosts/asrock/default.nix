{config, ...}: {
  unify.hosts.nixos.asrock = {
    modules = with config.unify.modules; [
      disk-btrfs-on-luks-with-raid0
      pc
      dev
      desktop-plasma
      gaming
    ];

    users.jaden.modules = config.unify.hosts.nixos.asrock.modules;

    disk-layout = {
      disk0 = "/dev/nvme0n1";
      disk1 = "/dev/nvme1n1";
      enableSwap = true;
      swapSize = 4;
      enableDiscards = true;
    };
    nixos = {
      system.stateVersion = "25.05";
      hardware.facter.reportPath = ./facter.json;
      networking = {
        hostName = "asrock";
      };

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
    home = {
      programs.ssh.matchBlocks = {
        aesop.hostname = "192.168.1.213";
        dokja.hostname = "194.163.175.110";
        teemo.hostname = "192.168.1.3";
      };
    };
  };
}
