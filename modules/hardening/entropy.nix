{
  unify.nixos = {
    services.jitterentropy-rngd.enable = true;
    boot.kernelModules = ["jitterentropy_rng"];
  };
}
