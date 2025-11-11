{
  flake.modules.nixos.hardening = {
    networking.networkmanager.wifi = {
      scanRandMacAddress = true;
      macAddress = "random";
    };
  };
}
