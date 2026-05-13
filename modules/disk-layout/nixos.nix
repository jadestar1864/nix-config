{
  inputs,
  lib,
  ...
}: {
  den.default.nixos.imports = [inputs.disko.nixosModules.disko];

  den.schema.host.options.disk-layout = with lib; {
    disk0 = mkOption {
      type = types.str;
      description = "The name of the primary physical disk";
    };
    disk1 = mkOption {
      type = types.str;
      description = "The name of the secondary physical disk";
      default = null;
    };
    espPartitionType = mkOption {
      type = types.str;
      description = "The partition type of the ESP partition";
      default = "EF00";
    };
    enableSwap = mkEnableOption "swap";
    swapSize = mkOption {
      type = types.ints.positive;
      description = "The size of available swap in MB";
    };
    enableDiscards = mkEnableOption "discards for LUKS";
  };
}
