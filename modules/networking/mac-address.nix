{
  unify.modules.pc.nixos = {
    networking.networkmanager.wifi = {
      scanRandMacAddress = true;
      macAddress = "random";
    };
  };
}
