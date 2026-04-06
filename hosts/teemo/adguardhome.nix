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
          upstream_dns = ["127.0.0.1:5335"];
          upstream_mode = "load_balance";
          fallback_dns = [
            "https://dns.mullvad.net/dns-query"
            "https://dns.cloudflare.com/dns-query"
            "tls://dns10.quad9.net"
            "tls://p0.freedns.controld.com"
            "tls://unfiltered.adguard-dns.com"
          ];
          bootstrap_dns = [
            "9.9.9.9"
            "149.112.112.112"
          ];
          enable_dnssec = true;
          aaaa_disabled = true;

          # Rely on unbound cache instead
          cache_enabled = false;
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
            "https://codeberg.org/hagezi/mirror2/raw/branch/main/dns-blocklists/adblock/tif.txt"
          ];
      };
    };
  };
}
