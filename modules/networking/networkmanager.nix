{
  den.aspects.pc.nixos = {
    networking.networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };
  };
}
