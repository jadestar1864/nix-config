{
  unify.hosts.nixos.dokja.nixos = {config, ...}: {
    # SOPS secret for ACME certificate management
    sops.secrets.cloudflare_api_token = {
      owner = "nginx";
      group = "nginx";
    };

    # ACME Certificate Management for wildcard certificate
    security.acme.certs = {
      "jadestar.dev-wildcard" = {
        domain = "*.jadestar.dev";
        email = "admin@jadestar.dev";
        dnsProvider = "cloudflare";
        group = "nginx";
        credentialFiles = {
          CF_DNS_API_TOKEN_FILE = config.sops.secrets.cloudflare_api_token.path;
        };
      };
      "jellyfin.jadestar.dev-wildcard" = {
        domain = "*.jellyfin.jadestar.dev";
        email = "admin@jadestar.dev";
        dnsProvider = "cloudflare";
        group = "nginx";
        credentialFiles = {
          CF_DNS_API_TOKEN_FILE = config.sops.secrets.cloudflare_api_token.path;
        };
      };
    };
    security.acme.acceptTerms = true;

    # Nginx reverse proxy gateway
    services.nginx = {
      enable = true;
      recommendedProxySettings = true;

      # Trust wireguard and docker networks for client IP preservation
      commonHttpConfig = ''
        # Trust wireguard network (10.169.0.0/24) and docker networks
        set_real_ip_from 10.169.0.0/24;
        set_real_ip_from 172.16.0.0/12;
        set_real_ip_from 127.0.0.0/8;

        # Use X-Forwarded-For to extract original client IP through proxy chain
        real_ip_header X-Forwarded-For;
        real_ip_recursive on;
      '';

      virtualHosts = {
        # Route niks3 (localhost service)
        "niks3.jadestar.dev" = {
          forceSSL = true;
          useACMEHost = "jadestar.dev-wildcard";
          locations."/" = {
            proxyPass = "http://127.0.0.1:5751";
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
            '';
          };
        };

        # Route to teemo SWAG
        "actual.jadestar.dev" = {
          forceSSL = true;
          useACMEHost = "jadestar.dev-wildcard";
          locations."/" = {
            proxyPass = "https://10.169.0.3:443";
            extraConfig = ''
              proxy_ssl_server_name on;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
            '';
          };
        };

        "notes.jadestar.dev" = {
          forceSSL = true;
          useACMEHost = "jadestar.dev-wildcard";
          locations."/" = {
            proxyPass = "https://10.169.0.3:443";
            extraConfig = ''
              proxy_ssl_server_name on;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
            '';
          };
        };

        "journal.jadestar.dev" = {
          forceSSL = true;
          useACMEHost = "jadestar.dev-wildcard";
          locations."/" = {
            proxyPass = "https://10.169.0.3:443";
            extraConfig = ''
              proxy_ssl_server_name on;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
            '';
          };
        };

        "grafana.jadestar.dev" = {
          forceSSL = true;
          useACMEHost = "jadestar.dev-wildcard";
          locations."/" = {
            proxyPass = "https://10.169.0.3:443";
            extraConfig = ''
              proxy_ssl_server_name on;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
            '';
          };
        };

        # Route to aesop SWAG - uses separate ACME cert for *.jellyfin.jadestar.dev
        "jellyfin.jadestar.dev" = {
          forceSSL = true;
          useACMEHost = "jellyfin.jadestar.dev-wildcard";
          locations."/" = {
            proxyPass = "https://10.169.0.5:443";
            extraConfig = ''
              proxy_ssl_server_name on;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
            '';
          };
        };

        "seerr.jellyfin.jadestar.dev" = {
          forceSSL = true;
          useACMEHost = "jellyfin.jadestar.dev-wildcard";
          locations."/" = {
            proxyPass = "https://10.169.0.5:443";
            extraConfig = ''
              proxy_ssl_server_name on;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
            '';
          };
        };

        "wizarr.jellyfin.jadestar.dev" = {
          forceSSL = true;
          useACMEHost = "jellyfin.jadestar.dev-wildcard";
          locations."/" = {
            proxyPass = "https://10.169.0.5:443";
            extraConfig = ''
              proxy_ssl_server_name on;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
            '';
          };
        };

        "ntfy.jadestar.dev" = {
          forceSSL = true;
          useACMEHost = "jadestar.dev-wildcard";
          locations."/" = {
            proxyPass = "https://10.169.0.5:443";
            extraConfig = ''
              proxy_ssl_server_name on;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
            '';
          };
        };

        # Arr subdomains (converted from subfolders) - use separate ACME cert for *.jellyfin.jadestar.dev
        "bazarr.jellyfin.jadestar.dev" = {
          forceSSL = true;
          useACMEHost = "jellyfin.jadestar.dev-wildcard";
          locations."/" = {
            proxyPass = "https://10.169.0.5:443";
            extraConfig = ''
              proxy_ssl_server_name on;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
            '';
          };
        };

        "sonarr.jellyfin.jadestar.dev" = {
          forceSSL = true;
          useACMEHost = "jellyfin.jadestar.dev-wildcard";
          locations."/" = {
            proxyPass = "https://10.169.0.5:443";
            extraConfig = ''
              proxy_ssl_server_name on;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
            '';
          };
        };

        "radarr.jellyfin.jadestar.dev" = {
          forceSSL = true;
          useACMEHost = "jellyfin.jadestar.dev-wildcard";
          locations."/" = {
            proxyPass = "https://10.169.0.5:443";
            extraConfig = ''
              proxy_ssl_server_name on;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
            '';
          };
        };

        "prowlarr.jellyfin.jadestar.dev" = {
          forceSSL = true;
          useACMEHost = "jellyfin.jadestar.dev-wildcard";
          locations."/" = {
            proxyPass = "https://10.169.0.5:443";
            extraConfig = ''
              proxy_ssl_server_name on;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
            '';
          };
        };
      };
    };
  };
}
