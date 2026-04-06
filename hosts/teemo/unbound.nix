{
  unify.hosts.nixos.teemo.nixos = {pkgs, ...}: {
    # sysctl values for increased buf size
    boot.kernel.sysctl = {
      "net.core.rmem_default" = 2097152;
      "net.core.wmem_default" = 2097152;
      "net.core.rmem_max" = 4104304;
      "net.core.wmem_max" = 4194304;
    };

    services.unbound = {
      enable = true;
      package = pkgs.unbound-with-systemd;
      enableRootTrustAnchor = true;
      settings = {
        # Adapted from https://github.com/saint-lascivious/unbound-config

        server = {
          # === Base ===
          interface = ["0.0.0.0"];
          port = 5335;
          do-ip4 = "yes";
          do-tcp = "yes";
          do-udp = "yes";
          prefer-ip4 = "yes";
          # Added by enableRootTrustAnchor above
          #auto-trust-anchor-file = "${config.services.unbound.stateDir}/root.key";

          # === Buffers ===
          so-rcvbuf = "4m";
          so-sndbuf = "4m";

          # === Caches ===
          msg-cache-slabs = 4;
          rrset-cache-slabs = 4;
          infra-cache-slabs = 4;
          key-cache-slabs = 4;
          rrset-cache-size = "8m";
          msg-cache-size = "4m";
          key-cache-size = "4m";
          neg-cache-size = "4m";

          # === Cache TTL ===
          cache-max-ttl = 86400;
          cache-min-ttl = 300;

          # === EDNS Buffer Size ===
          edns-buffer-size = 1232;

          # === Address Capitalization Randomization ===
          use-caps-for-id = "yes";

          # === Hardening ===
          harden-short-bufsize = "yes";
          harden-glue = "yes";
          harden-dnssec-stripped = "yes";
          harden-below-nxdomain = "yes";
          harden-referral-path = "yes";
          harden-algo-downgrade = "yes";
          aggressive-nsec = "yes";

          # === Libevent ===
          outgoing-range = 8192;
          num-queries-per-thread = 4096;

          # === Multithreading UDP ===
          so-reuseport = "yes";

          # === Multithreading ===
          num-threads = 2;

          # === Prefetch ===
          prefetch = "yes";
          prefetch-key = "yes";

          # === Private ranges ===
          private-address = [
            "192.168.0.0/16"
            "169.254.0.0/16"
            "172.16.0.0/12"
            "10.0.0.0/8"
            "fd00::/8"
            "fe80::/10"
          ];

          # === Root hints ===
          root-hints = "${pkgs.dns-root-data}/root.hints";
        };
      };
    };
  };
}
