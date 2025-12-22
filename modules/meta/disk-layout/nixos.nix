{lib, ...}: let
  inherit (lib) mkEnableOption mkOption types;
in {
  unify.options.disk-layout = mkOption {
    type = types.submodule {
      options = {
        disk0 = mkOption {
          type = types.str;
          description = "The name of the first physical disk";
        };
        disk1 = mkOption {
          type = types.str;
          description = "The name of the second physical disk";
        };
        espPartitionType = mkOption {
          type = types.str;
          description = "The partition type of the ESP partition";
          default = "EF00";
        };
        extraLuksFormatArgs = mkOption {
          type = types.nullOr (types.listOf types.str);
          description = "Extra arguments for `cryptsetup luksFormat`";
          default = null;
        };
        enableSwap = mkEnableOption "swap";
        swapSize = mkOption {
          type = types.ints.positive;
          description = "The size of available swap in GB";
        };
        enableDiscards = mkEnableOption "discards for LUKS";
      };
    };
  };
}
