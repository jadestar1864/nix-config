{lib, ...}: {
  flake.modules.nixos.base = {
    options.disk-layout = {
      disk0 = lib.mkOption {
        type = lib.types.string;
        description = "The name of the first physical disk";
      };
      disk1 = lib.mkOption {
        type = lib.types.string;
        description = "The name of the second physical disk";
      };

      enableSwap = lib.mkEnableOption "swap";
      swapSize = lib.mkOption {
        type = lib.types.ints.positive;
        description = "The size of available swap in GB";
      };

      enableDiscards = lib.mkEnableOption "discards for LUKS";
    };
  };
}
