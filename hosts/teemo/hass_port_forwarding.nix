{
  den.aspects.teemo.nixos = {
    networking = {
      firewall.allowedTCPPorts = [8123];
      nat = {
        enable = true;
        internalInterfaces = ["wg0"];
        externalInterface = "end0";
        forwardPorts = [
          {
            sourcePort = 8123;
            proto = "tcp";
            destination = "192.168.1.6:8123";
          }
        ];
      };
    };
  };
}
