{lib, ...}: {
  flake.modules.nixos.base = {
    options.networking.primaryInterface = lib.mkOption {
      type = lib.types.str;
      description = "The name of the primary interface used for networking";
    };
  };
}
