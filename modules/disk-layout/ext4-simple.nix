{lib, ...}: {
  den.aspects.disk-layout.provides.ext4-simple.nixos = {host, ...}: {
    disko.devices.disk = {
      disk0 = {
        type = "disk";
        device = host.disk-layout.disk0;
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "512M";
              type = host.disk-layout.espPartitionType;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "umask=0077"
                ];
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
              size = "${toString host.disk-layout.swapSize}M";
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
