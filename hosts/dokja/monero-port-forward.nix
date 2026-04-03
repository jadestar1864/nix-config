{
  unify.hosts.nixos.dokja.nixos = {
    networking = {
      firewall.allowedTCPPorts = [18080 18089];
      nat.forwardPorts = [
        {
          proto = "tcp";
          sourcePort = 18080;
          destination = "10.169.0.3:18080";
        }
        {
          proto = "tcp";
          sourcePort = 18089;
          destination = "10.169.0.3:18089";
        }
      ];
    };
  };
}
