{
  unify.hosts.nixos.dokja.nixos = {
    config,
    pkgs,
    ...
  }: {
    sops.secrets.cloudflare_api_token_file = {
      owner = config.services.caddy.user;
      group = config.services.caddy.group;
    };

    services.caddy = {
      enable = true;
      environmentFile = config.sops.secrets.cloudflare_api_token_file.path;
      package = pkgs.caddy.withPlugins {
        plugins = [
          "github.com/caddy-dns/cloudflare@v0.2.2"
          "github.com/caddyserver/transform-encoder@v0.0.0-20251203163749-3574c321422b"
        ];
        hash = "sha256-GLgzXr4KCYQyQWNAHaNqU2pIxHqZyGfizYTynhqbpHs=";
      };
      virtualHosts = let
        simpleRp = domain: endpoint: {
          logFormat = ''
            format transform "{common_log}"
            output file /var/log/${domain}/access.log
          '';
          extraConfig = ''
            reverse_proxy http://${domain}
            tls {
              dns cloudflare {env.CLOUDFLARE_DNS_API_TOKEN}
            }
          '';
        };
        realIp = endpoint: ''
          reverse_proxy http://${endpoint} {
            header_down X-Real-IP {http.request.remote}
            header_down X-Forwarded-For {http.request.remote}
          }
        '';
        simpleRealIpRp = domain: endpoint: {
          logFormat = ''
            format transform "{common_log}"
            output file /var/log/${domain}/access.log
          '';
          extraConfig = ''
            ${realIp endpoint}
            tls {
              dns cloudflare {env.CLOUDFLARE_DNS_API_TOKEN}
            }
          '';
        };
      in {
        "niks3.jadestar.dev" = simpleRp "niks3.jadestar.dev" "127.0.0.1:5751";
        "ntfy.jadestar.dev" = simpleRealIpRp "ntfy.jadestar.dev" "10.169.0.5:2586";
        "jellyfin.jadestar.dev" = {
          logFormat = ''
            format transform "{common_log}"
            output file /var/log/jellyfin.jadestar.dev/access.log
          '';
          extraConfig = ''
            handle /sonarr/* {
              ${realIp "10.169.0.5:8989"}
            }
            handle /radarr/* {
              ${realIp "10.169.0.5:7878"}
            }
            handle /* {
              ${realIp "10.169.0.5:8096"}
            }
            tls {
              dns cloudflare {env.CLOUDFLARE_DNS_API_TOKEN}
            }
          '';
        };
        "wizarr.jellyfin.jadestar.dev" = simpleRealIpRp "wizarr.jellyfin.jadestar.dev" "10.169.0.5:5690";
        "seerr.jellyfin.jadestar.dev" = simpleRealIpRp "seerr.jellyfin.jadestar.dev" "10.169.0.5:5055";
      };
    };
  };
}
