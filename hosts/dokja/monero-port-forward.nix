{
  unify.hosts.nixos.dokja.nixos = {
    networking = {
      firewall.allowedTCPPorts = [
        18080
        18083
        18089
        37888
      ];
      nat.forwardPorts = [
        {
          proto = "tcp";
          sourcePort = 18080;
          destination = "10.169.0.3:18080";
        }
        {
          proto = "tcp";
          sourcePort = 18083;
          destination = "10.169.0.3:18083";
        }
        {
          proto = "tcp";
          sourcePort = 18089;
          destination = "10.169.0.3:18089";
        }
        {
          proto = "tcp";
          sourcePort = 37888;
          destination = "10.169.0.5:37888";
        }
      ];
    };
  };
}
