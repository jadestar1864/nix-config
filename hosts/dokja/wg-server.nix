{
  unify.hosts.nixos.dokja.nixos = {
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
      teemo_preshared_key = {
        sopsFile = ../../secrets/hosts/dokja-teemo.yml;
        key = "wg_preshared_key";
        mode = "640";
        owner = "systemd-network";
        group = "systemd-network";
      };
    };

    environment.systemPackages = [pkgs.wireguard-tools];

    networking.useNetworkd = true;
    networking.firewall.allowedUDPPorts = [51820];
    networking.nat = {
      enable = true;
      externalInterface = "ens18";
      internalInterfaces = ["wg0"];
    };

    systemd.network = {
      networks."50-wg0" = {
        matchConfig.Name = "wg0";
        networkConfig.IPv4Forwarding = true;

        address = ["10.169.0.1/24"];
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
            PublicKey = "nJhCcdB6Pzu7eZdNm195JICttp8btDcrIJtamyR+uGw=";
            PresharedKeyFile = config.sops.secrets.teemo_preshared_key.path;
            AllowedIPs = ["10.169.0.3/32"];
          }
        ];
      };
    };
  };
}
