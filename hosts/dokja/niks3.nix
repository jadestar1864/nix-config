{
  unify.hosts.nixos.dokja.nixos = {config, ...}: {
    sops.secrets = {
      r2_access_key = {
        owner = config.services.niks3.user;
        group = config.services.niks3.group;
      };
      r2_secret_key = {
        owner = config.services.niks3.user;
        group = config.services.niks3.group;
      };
      niks3_signing_key = {
        owner = config.services.niks3.user;
        group = config.services.niks3.group;
      };
      niks3_auth_token = {
        owner = config.services.niks3.user;
        group = config.services.niks3.group;
      };
    };

    services.niks3 = {
      enable = true;
      httpAddr = "127.0.0.1:5751";

      # S3 configuration
      s3 = {
        endpoint = "d453ef990b5969947e8dc16a0962cef8.r2.cloudflarestorage.com";
        bucket = "niks3";
        useSSL = true;
        accessKeyFile = config.sops.secrets.r2_access_key.path;
        secretKeyFile = config.sops.secrets.r2_secret_key.path;
      };

      # API authentication token (minimum 36 characters)
      apiTokenFile = config.sops.secrets.niks3_auth_token.path;

      # Signing keys for NAR signing
      signKeyFiles = [config.sops.secrets.niks3_signing_key.path];

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
  };
}
