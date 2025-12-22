{lib, ...}: {
  unify.modules.disk-ext4-simple.nixos = {hostConfig, ...}: {
    disko.devices.disk = {
      disk0 = {
        type = "disk";
        device = hostConfig.disk-layout.disk0;
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "512M";
              type = hostConfig.disk-layout.espPartitionType;
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
              size = lib.mkIf (!hostConfig.disk-layout.enableSwap) "100%";
              end = lib.mkIf hostConfig.disk-layout.enableSwap "-${toString hostConfig.disk-layout.swapSize}G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
            encryptedSwap = lib.mkIf hostConfig.disk-layout.enableSwap {
              size = "${toString hostConfig.disk-layout.swapSize}G";
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
