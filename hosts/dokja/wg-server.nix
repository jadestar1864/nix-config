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
      aesop_preshared_key = {
        sopsFile = ../../secrets/hosts/aesop-dokja.yml;
        key = "wg_preshared_key";
        mode = "640";
        owner = "systemd-network";
        group = "systemd-network";
      };
      thinkpadx1_preshared_key = {
        sopsFile = ../../secrets/hosts/dokja-thinkpadx1.yml;
        key = "wg_preshared_key";
        mode = "640";
        owner = "systemd-network";
        group = "systemd-network";
      };
    };

    environment.systemPackages = [pkgs.wireguard-tools];

    networking.useNetworkd = true;
    networking.firewall.allowedUDPPorts = [51820];
    /*
    networking.firewall.extraCommands = ''
      iptables -A FORWARD -i wg+ -j ACCEPT
      iptables -t nat -A POSTROUTING -s 10.169.0.0/24 -o wg0 -j MASQUERADE
    '';
    */
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
          {
            PublicKey = "7YRBANxU4ZDUjWRKgDzSpQgY4QKIoKCh5tp1z+DpWkM=";
            PresharedKeyFile = config.sops.secrets.aesop_preshared_key.path;
            AllowedIPs = ["10.169.0.5/32"];
          }
          {
            PublicKey = "6hWlt5QltfIeh3xK0k2OH8YI75TSWz/j/Nxm5WsXMTg=";
            PresharedKeyFile = config.sops.secrets.thinkpadx1_preshared_key.path;
            AllowedIPs = ["10.169.0.7/32"];
          }
        ];
      };
    };
  };
}
