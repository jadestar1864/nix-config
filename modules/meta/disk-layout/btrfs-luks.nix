{lib, ...}: {
  unify.modules.disk-btrfs-on-luks.nixos = {hostConfig, ...}: {
    # Bind mount /var/tmp to /tmp
    fileSystems."/tmp" = {
      device = "/var/tmp";
      options = ["bind"];
    };

    boot.loader.efi.efiSysMountPoint = "/efi";
    virtualisation.docker.storageDriver = "btrfs";

    disko.devices.disk = {
      disk0 = {
        type = "disk";
        device = hostConfig.disk-layout.disk0;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = hostConfig.disk-layout.espPartitionType;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/efi";
                mountOptions = [
                  "umask=0077"
                ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                askPassword = true;
                settings.allowDiscards = hostConfig.disk-layout.enableDiscards;
                extraFormatArgs = lib.mkIf (hostConfig.disk-layout.extraLuksFormatArgs != null) hostConfig.disk-layout.extraLuksFormatArgs;
                content = {
                  type = "btrfs";
                  extraArgs = ["-f"];
                  subvolumes = let
                    commonOpts = ["defaults" "compress-force=zstd" "space_cache=v2" "noatime"];
                  in {
                    "/@" = {
                      mountpoint = "/";
                      mountOptions = commonOpts;
                    };
                    "/@var" = {
                      mountpoint = "/var";
                      mountOptions = commonOpts;
                    };
                    "/@vartmp" = {
                      mountpoint = "/var/tmp";
                      mountOptions = commonOpts ++ ["nodev" "nosuid"];
                    };
                    "/@varlog" = {
                      mountpoint = "/var/log";
                      mountOptions = commonOpts;
                    };
                    "/@home" = {
                      mountpoint = "/home";
                      mountOptions = commonOpts ++ ["nodev"];
                    };
                    "/@nix" = {
                      mountpoint = "/nix";
                      mountOptions = commonOpts;
                    };
                    "/@swap" = lib.mkIf hostConfig.disk-layout.enableSwap {
                      mountpoint = "/swap";
                      swap.swapfile.size = "${toString hostConfig.disk-layout.swapSize}G";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
