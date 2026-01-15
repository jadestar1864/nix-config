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
        simpleRealIpRp = domain: endpoint: {
          logFormat = ''
            format transform "{common_log}"
            output file /var/log/${domain}/access.log
          '';
          extraConfig = ''
            reverse_proxy http://${endpoint} {
              header_down X-Real-IP {http.request.remote}
              header_down X-Forwarded-For {http.request.remote}
            }
            tls {
              dns cloudflare {env.CLOUDFLARE_DNS_API_TOKEN}
            }
          '';
        };
      in {
        "niks3.jadestar.dev" = {
          logFormat = ''
            format transform "{common_log}"
            output file /var/log/niks3.jadestar.dev/access.log
          '';
          extraConfig = ''
            reverse_proxy http://127.0.0.1:5751
            tls {
              dns cloudflare {env.CLOUDFLARE_DNS_API_TOKEN}
            }
          '';
        };
        "jellyfin.jadestar.dev" = simpleRealIpRp "jellyfin.jadestar.dev" "10.169.0.5:8096";
        "prowlarr.jellyfin.jadestar.dev" = simpleRealIpRp "prowlarr.jellyfin.jadestar.dev" "10.169.0.5:9696";
        "sonarr.jellyfin.jadestar.dev" = simpleRealIpRp "sonarr.jellyfin.jadestar.dev" "10.169.0.5:8989";
        "radarr.jellyfin.jadestar.dev" = simpleRealIpRp "radarr.jellyfin.jadestar.dev" "10.169.0.5:7878";
        "wizarr.jellyfin.jadestar.dev" = simpleRealIpRp "radarr.jellyfin.jadestar.dev" "10.169.0.5:5690";
      };
    };
  };
}
