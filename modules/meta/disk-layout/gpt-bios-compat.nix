{lib, ...}: {
  unify.modules.disk-gpt-bios-compat.nixos = {hostConfig, ...}: {
    disko.devices.disk = {
      disk0 = {
        type = "disk";
        device = hostConfig.disk-layout.disk0;
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
              end = "-${toString hostConfig.disk-layout.swapSize}G";
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
