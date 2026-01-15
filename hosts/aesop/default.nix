{config, ...}: {
  unify.hosts.nixos.aesop = {
    modules = with config.unify.modules; [
      disk-ext4-simple
    ];

    users.jaden.modules = config.unify.hosts.nixos.aesop.modules;

    disk-layout = {
      disk0 = "/dev/disk/by-id/nvme-WPBSNM8-512GTP_WWDD250807047011727";
      enableSwap = true;
      swapSize = 4;
    };

    nixos = {modulesPath, ...}: {
      imports = [
        "${modulesPath}/profiles/minimal.nix"
      ];

      services.openssh.enable = true;
      services.usbguard.enable = false;
      powerManagement.cpuFreqGovernor = "ondemand";

      system.stateVersion = "25.11";
      facter.reportPath = ./facter.json;
      networking = {
        networkmanager.enable = false;
        useDHCP = false;
        hostName = "aesop";
      };

      systemd.network.enable = true;
      systemd.network.networks."10-wan" = {
        matchConfig.Name = "enp1s0";
        address = ["192.168.1.213/24"];
        routes = [
          {Gateway = "192.168.1.254";}
        ];
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };
}
