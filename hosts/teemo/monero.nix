{
  unify.hosts.nixos.teemo.nixos = {
    networking.firewall.interfaces.wg0.allowedTCPPorts = [18080 18089];

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
        out-peers=12
        in-peers=48
      '';
    };
  };
}
