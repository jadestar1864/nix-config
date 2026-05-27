{lib, ...}: {
  den.aspects.disk-layout.provides.btrfs-on-luks.nixos = {host, ...}: {
    # Bind mount /var/tmp to /tmp
    fileSystems."/tmp" = {
      fsType = "auto";
      device = "/var/tmp";
      options = ["bind"];
    };

    boot.loader.efi.efiSysMountPoint = "/efi";
    virtualisation.docker.storageDriver = "btrfs";

    disko.devices.disk = {
      disk0 = {
        type = "disk";
        device = host.disk-layout.disk0;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = host.disk-layout.espPartitionType;
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
                settings.allowDiscards = host.disk-layout.enableDiscards;
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
                    "/@swap" = lib.mkIf host.disk-layout.enableSwap {
                      mountpoint = "/swap";
                      swap.swapfile.size = "${toString host.disk-layout.swapSize}M";
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
