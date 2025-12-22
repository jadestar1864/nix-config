{
  unify.hosts.nixos.teemo.nixos = {
    system.autoUpgrade = {
      enable = true;
      flake = "github:jadestar1864/nix-config";
      flags = ["-L" "--accept-flake-config"];
      dates = "09:00 UTC";
      randomizedDelaySec = "45min";
      allowReboot = true;
      rebootWindow = {
        lower = "10:00";
        upper = "14:00";
      };
    };
  };
}
