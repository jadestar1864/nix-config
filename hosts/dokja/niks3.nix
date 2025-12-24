{
  unify.hosts.nixos.dokja.nixos = {pkgs, ...} @ nixosConfig: {
    services.niks3 = {
      enable = true;
      httpAddr = "127.0.0.1:5751";

      # S3 configuration
      s3 = {
        endpoint = "d453ef990b5969947e8dc16a0962cef8.r2.cloudflarestorage.com";
        bucket = "niks3";
        useSSL = true;
        accessKeyFile = nixosConfig.config.sops.secrets.r2_access_key.path;
        secretKeyFile = nixosConfig.config.sops.secrets.r2_secret_key.path;
      };

      # API authentication token (minimum 36 characters)
      apiTokenFile = nixosConfig.config.sops.secrets.niks3_auth_token.path;

      # Signing keys for NAR signing
      signKeyFiles = [nixosConfig.config.sops.secrets.niks3_signing_key.path];

      # Public cache URL (optional) - if exposed via https
      # Generates a landing page with usage instructions and public keys
      cacheUrl = "https://cache.jadestar.dev";

      # Nginx reverse proxy (optional)
      nginx = {
        enable = false;
        # Domain for the niks3 server, not for the binary cache.
        # This is used by `niks3 push`
        domain = "niks3.jadestar.dev";
        # enableACME = true;      # default
        # forceSSL = true;        # default
      };

      oidc.providers.github = {
        issuer = "https://token.actions.githubusercontent.com";
        audience = "https://niks3.jadestar.dev";
        boundClaims = {
          repository_owner = ["jadestar1864"];
        };
        boundSubject = ["repo:jadestar1864/*:*"];
      };
    };

    services.caddy = {
      enable = true;
      environmentFile = nixosConfig.config.sops.secrets.cloudflare_api_token_file.path;
      package = pkgs.caddy.withPlugins {
        plugins = [
          "github.com/caddy-dns/cloudflare@v0.2.2"
          "github.com/caddyserver/transform-encoder@v0.0.0-20251203163749-3574c321422b"
        ];
        hash = "sha256-GLgzXr4KCYQyQWNAHaNqU2pIxHqZyGfizYTynhqbpHs=";
      };
      virtualHosts."niks3.jadestar.dev" = {
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
    };
  };
}
