{
  unify.hosts.nixos.dokja.nixos = {config, ...}: {
    sops.secrets = {
      wg_private_key = {
        mode = "640";
        owner = "systemd-networkd";
        group = "systemd-networkd";
      };
      teemo_preshared_key = {
        sopsFile = "../../secrets/hosts/dokja-teemo.yml";
        key = "wg_preshared_key";
        mode = "640";
        owner = "systemd-networkd";
        group = "systemd-networkd";
      };
    };

    networking.useNetworkd = true;
    networking.firewall.allowedUDPPorts = [51820];
    networking.nat = {
      enable = true;
      enableIPv6 = true;
      externalInterface = "ens18";
      internalInterfaces = ["wg0"];
    };

    systemd.network = {
      networks."50-wg0" = {
        matchConfig.Name = "wg0";
        IPv4Forwarding = true;
        IPv6Forwarding = true;

        address = [
          "fd31:bf08:57cb::7/128"
          "10.169.0.1/32"
        ];
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
            PublicKey = "re+5pmxzZx0cVrRKXoT4NsILcBmnJ16v6fTwC3A+TxU=";
            PresharedKeyFile = config.sops.secrets.teemo_preshared_key.path;
            AllowedIPs = [
              "fd31:bf08:57cb::9/128"
              "10.169.0.3/32"
            ];
          }
        ];
      };
    };
  };
}
