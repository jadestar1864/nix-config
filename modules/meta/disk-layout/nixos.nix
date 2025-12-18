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
