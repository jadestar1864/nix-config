{lib, ...}: {
  den.aspects.disk-layout.provides.gpt-bios-compat.nixos = {host, ...}: {
    disko.devices.disk = {
      disk0 = {
        type = "disk";
        device = host.disk-layout.disk0;
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02"; # for grub MBR
              content = {
                type = "filesystem";
                format = "vfat";
              };
            };
            root = {
              size = lib.mkIf (!host.disk-layout.enableSwap) "100%";
              end = lib.mkIf host.disk-layout.enableSwap "-${toString host.disk-layout.swapSize}M";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
            encryptedSwap = lib.mkIf host.disk-layout.enableSwap {
              size = "${toString host.disk-layout.swapSize}G";
              content = {
                type = "swap";
                randomEncryption = true;
              };
            };
          };
        };
      };
    };
  };
}
