{
  config,
  inputs,
  ...
}: {
  unify.hosts.nixos.teemo = {
    modules = with config.unify.modules; [
      disk-btrfs-on-luks
    ];

    users.jaden.modules = config.unify.hosts.nixos.teemo.modules;

    disk-layout = {
      disk0 = "/dev/disk/by-id/usb-USB_SanDisk_3.2Gen1_03020405050625094732-0:0";
      enableSwap = true;
      swapSize = 4;
    };

    nixos = {
      imports = [
        inputs.nixos-hardware.nixosModules.raspberry-pi-4
      ];

      hardware.raspberry-pi."4".apply-overlays-dtmerge.enable = true;
      boot.loader.generic-extlinux-compatible.enable = false;

      # RPi has no RTC
      services.chrony.extraFlags = ["-s"];

      system.stateVersion = "25.11";
      facter.reportPath = ./facter.json;
      networking = {
        networkmanager.enable = false;
        useDHCP = false;
        hostName = "teemo";
      };

      systemd.network.enable = true;
      systemd.network.networks."10-wan" = {
        matchConfig.Name = "end0";
        address = ["192.168.1.3/24"];
        routes = [
          {Gateway = "192.168.1.254";}
        ];
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };
}
