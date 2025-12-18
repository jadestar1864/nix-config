{lib, ...}: let
  unfreeModule = {config, ...}: let
    inherit (lib) mkOption types;
  in {
    options.nixpkgs.allowedUnfreePackages = mkOption {
      type = types.listOf types.str;
      default = [];
    };

    config = let
      predicate = pkg: builtins.elem (lib.getName pkg) config.nixpkgs.allowedUnfreePackages;
    in {
      nixpkgs.config.allowUnfreePredicate = predicate;
    };
  };
in {
  unify = {
    nixos.imports = [unfreeModule];
    home = args: {
      imports = lib.optional (!(args.hasGlobalPkgs or false)) unfreeModule;
    };
  };
}
