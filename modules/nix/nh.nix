{lib, ...}: {
  unify.nixos = {hostConfig, ...}: {
    programs.nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 3d --keep 5";
      };
      flake = lib.mkDefault hostConfig.nixConfigPath;
    };
  };
}
