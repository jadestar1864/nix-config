{lib, ...}: {
  den.schema.host.options.nix-config-path = with lib;
    mkOption {
      type = types.nullOr types.str;
      description = "Path to the nix configuration on the host";
      default = null;
    };
}
