{lib, ...}: {
  den.default.nixos = {host, ...}: {
    programs.nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 3d --keep 5";
      };
      flake = lib.mkDefault host.nix-config-path;
    };
  };
}
