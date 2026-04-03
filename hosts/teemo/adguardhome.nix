{
  unify.hosts.nixos.teemo.nixos = {
    services.resolved.extraConfig = ''
      [Resolve]
      DNS=127.0.0.1
      DNSStubListener=no
    '';

    networking.firewall = {
      allowedTCPPorts = [53 68];
      allowedUDPPorts = [53 67 68];
    };

    services.adguardhome = {
      enable = true;
      host = "0.0.0.0";
      port = 3003;
      openFirewall = true;
      mutableSettings = false;
      settings = {
        users = [
          {
            name = "admin";
            password = "$2a$12$hBU0ryu5YN8jXyHzsnUP2erLVz/q3081yWfUgqB1qnfCo2XGaH3Qu";
          }
        ];
        dns = {
          upstream_dns = [
            "https://dns.mullvad.net/dns-query"
            "https://dns.cloudflare.com/dns-query"
            "https://dns.quad9.net/dns-query"
          ];
          upstream_mode = "load_balance";
          bootstrap_dns = [
            "1.1.1.1"
            "1.0.0.1"
          ];
          enable_dnssec = true;
          aaaa_disabled = true;
        };
        dhcp = {
          enabled = true;
          interface_name = "end0";
          dhcpv4 = {
            gateway_ip = "192.168.1.254";
            subnet_mask = "255.255.255.0";
            range_start = "192.168.1.64";
            range_end = "192.168.1.253";
          };
        };
        filtering = {
          protection_enabled = true;
          filtering_enabled = true;
        };
        filters =
          map (url: {
            enabled = true;
            url = url;
          }) [
            "https://codeberg.org/hagezi/mirror2/raw/branch/main/dns-blocklists/adblock/multi.txt"
          ];
      };
    };
  };
}
