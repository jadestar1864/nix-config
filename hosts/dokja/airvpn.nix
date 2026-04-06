{
  unify.hosts.nixos.dokja.nixos = {config, ...}: {
    /*
    sops.secrets = {
      airvpn_private_key = {
        mode = "640";
        owner = "systemd-network";
        group = "systemd-network";
      };
      airvpn_preshared_key = {
        mode = "640";
        owner = "systemd-network";
        group = "systemd-network";
      };
    };

    networking.firewall.allowedUDPPorts = [51821];
    networking.firewall.checkReversePath = "loose";

    systemd.network = {
      netdevs."51-wg-airvpn" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg-airvpn";
        };

        wireguardConfig = {
          ListenPort = 51821;

          PrivateKeyFile = config.sops.secrets.airvpn_private_key.path;
        };
        wireguardPeers = [
          {
            PublicKey = "PyLCXAQT8KkM4T+dUsOQfn+Ub3pGxfGlxkIApuig+hk=";
            PresharedKeyFile = config.sops.secrets.airvpn_preshared_key.path;
            AllowedIPs = ["10.169.0.11/32"];
            Endpoint = "us3.vpn.airdns.org:1637";
            PersistentKeepalive = 15;
          }
        ];
      };

      networks."51-wg-airvpn" = {
        matchConfig.Name = "wg-airvpn";
        address = [
          "10.171.172.239/32"
          "fd7d:76ee:e68f:a993:987:f0f3:231:404f/128"
        ];
        routes = [
          {
            Destination = "0.0.0.0/0";
            Table = 132;
          }
        ];
        routingPolicyRules = [
          {
            Family = "both";
            From = "10.169.0.11";
            Table = 132;
            Priority = 100;
          }
        ];
      };
    };
    */
  };
}
