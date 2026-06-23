{den, ...}: {
  den.hosts.x86_64-linux.aesop = {
    hostName = "aesop";
    users = {
      admin = {};
      jaden = {};
    };
    disk-layout = {
      disk0 = "/dev/disk/by-id/nvme-WPBSNM8-512GTP_WWDD250807047011727";
      enableSwap = true;
      swapSize = 4096;
    };
  };
  den.aspects.aesop = {
    includes = with den.aspects; [
      disk-layout._.ext4-simple
      auto-upgrade
    ];
    nixos = {
      modulesPath,
      pkgs,
      ...
    }: {
      imports = [
        "${modulesPath}/profiles/minimal.nix"
      ];

      services.openssh.enable = true;
      users.users = {
        jaden.openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBXcvbsXQen1xvAtTJX/12+s9QsYuR3bu61NkLRM9/eH"
        ];
        admin.openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILf98pOpo9cwmMfuI7YrzP1mf5Oc+5n9esR1uZ3+qJ6+"
        ];
      };

      services.usbguard.enable = false;
      powerManagement.cpuFreqGovernor = "ondemand";

      hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
          intel-media-driver
          vpl-gpu-rt
          intel-compute-runtime
        ];
      };
      hardware.enableRedistributableFirmware = true;
      boot.kernelParams = [
        "i915.force_probe=46d2"
        "i915.enable_guc=3"
      ];
      environment.sessionVariables = {
        LIBVA_DRIVER_NAME = "iHD";
      };

      hardware.facter.reportPath = ./facter.json;
      networking = {
        networkmanager.enable = false;
        useDHCP = false;
      };

      systemd.network.enable = true;
      systemd.network.networks."10-wan" = {
        matchConfig.Name = "enp1s0";
        address = ["192.168.1.4/24"];
        routes = [
          {Gateway = "192.168.1.1";}
        ];
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };
}
