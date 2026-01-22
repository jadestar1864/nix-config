{
  unify.hosts.nixos.dokja.nixos = {
    networking.firewall.interfaces.wg0.allowedTCPPorts = [12345];

    # Force dbus-broker implementation so prometheus systemd exporter works
    # https://discourse.nixos.org/t/systemd-exporter-couldnt-get-dbus-connection-read-unix-run-dbus-system-bus-socket-recvmsg-connection-reset-by-peer/64367
    # https://github.com/NixOS/nixpkgs/issues/408800
    services.dbus.implementation = "broker";

    services.alloy = {
      enable = true;
      configPath = ./config.alloy;
      extraFlags = [
        "--disable-reporting"
      ];
    };
  };
}
