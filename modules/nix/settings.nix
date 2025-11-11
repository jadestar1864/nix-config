{
  inputs,
  lib,
  config,
  ...
}: {
  options.nix.settings = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.anything;
  };

  config = {
    nix.settings = {
      connect-timeout = 5;
      log-lines = 25;
      min-free = 128000000; # 128MB
      max-free = 1000000000; # 1GB

      auto-optimise-store = true;
      warn-dirty = false;

      experimental-features = ["nix-command" "flakes" "pipe-operators"];
    };
    flake.modules = let
      nix-attrs = nixosArgs: {
        nix = {
          inherit (config.nix) settings;

          # Add flake inputs as registry
          # Make nix3 commands consistent with flake
          registry = lib.mapAttrs (_: value: {flake = value;}) inputs;

          # Add inputs to system's legacy channel
          # Make legacy nix commands consistent with flake
          nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") nixosArgs.config.nix.registry;
        };
      };
    in {
      nixos.base = nix-attrs;
      homeManager.base = nix-attrs;
    };
  };
}
