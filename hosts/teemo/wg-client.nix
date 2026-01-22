{
  unify.hosts.nixos.teemo.nixos = {
    config,
    pkgs,
    ...
  }: {
    sops.secrets = {
      wg_private_key = {
        mode = "640";
        owner = "systemd-network";
        group = "systemd-network";
      };
      wg_preshared_key = {
        sopsFile = ../../secrets/hosts/dokja-teemo.yml;
        mode = "640";
        owner = "systemd-network";
        group = "systemd-network";
      };
    };

    environment.systemPackages = [pkgs.wireguard-tools];

    networking.useNetworkd = true;
    networking.firewall.allowedUDPPorts = [51820];
    networking.firewall.checkReversePath = "loose";

    systemd.network = {
      networks."50-wg0" = {
        matchConfig.Name = "wg0";

        address = ["10.169.0.3/32"];
      };

      netdevs."50-wg0" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg0";
        };

        wireguardConfig = {
          ListenPort = 51820;

          PrivateKeyFile = config.sops.secrets.wg_private_key.path;

          RouteTable = "main";
        };

        wireguardPeers = [
          {
            PublicKey = "pCwHRFMru2N8Gh/P3KZKcVdiOoqLFwJh3tKve/j8DwY=";
            PresharedKeyFile = config.sops.secrets.wg_preshared_key.path;
            AllowedIPs = ["10.169.0.0/24"];
            Endpoint = "194.163.175.110:51820";
            PersistentKeepalive = 25;
          }
        ];
      };
    };
  };
}
