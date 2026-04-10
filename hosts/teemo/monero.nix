{
  unify.hosts.nixos.teemo.nixos = {
    networking.firewall.interfaces.wg0.allowedTCPPorts = [
      18080
      18083
      18089
    ];

    services.monero = {
      enable = true;
      prune = true;
      rpc = {
        address = "10.169.0.3";
        port = 18089;
        restricted = true;
      };
      limits = {
        upload = 1048576;
        download = 1048576;
      };
      extraConfig = ''
        confirm-external-bind=1
        out-peers=32
        in-peers=64
        enforce-dns-checkpointing=1
        enable-dns-blocklist=1
        zmq-pub=tcp://10.169.0.3:18083
        add-priority-node=p2pmd.xmrvsbeast.com:18080
        add-priority-node=nodes.hashvault.pro:18080
      '';
    };
  };
}
