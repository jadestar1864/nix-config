{lib, ...}: let
  inherit (lib) mkOption types;
in {
  unify.options.primaryUser = mkOption {
    type = types.submodule {
      options = {
        name = mkOption {
          type = types.str;
          default = "Jaden Nola";
        };
        username = mkOption {
          type = types.str;
          default = "jaden";
        };
        email = mkOption {
          type = types.str;
          default = "proto@jadestar.dev";
        };
      };
    };
    default = {};
  };
}
