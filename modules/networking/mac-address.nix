{
  den.aspects.pc.nixos = {
    networking.networkmanager.wifi = {
      scanRandMacAddress = true;
      macAddress = "random";
    };
  };
}
