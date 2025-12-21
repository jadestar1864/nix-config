{
  config,
  inputs,
  ...
}: {
  unify.hosts.nixos.dokja = {
    modules = with config.unify.modules; [
      disk-gpt-bios-compat
    ];

    users.jaden.modules = config.unify.hosts.nixos.dokja.modules;

    disk-layout = {
      disk0 = "/dev/sda";
      enableSwap = true;
      swapSize = 2;
    };

    nixos = {pkgs, ...} @ nixosConfig: {
      imports = [inputs.niks3.nixosModules.niks3];

      system.stateVersion = "25.11";
      facter.reportPath = ./facter.json;
      networking = {
        networkmanager.enable = false;
        useDHCP = false;
        hostName = "dokja";
        nameservers = [
          "213.136.95.10"
          "213.136.95.11"
          "2a02:c207::1:53"
        ];
        firewall = {
          allowedTCPPorts = [80 443];
          allowedUDPPorts = [80 443];
        };
      };

      boot.loader = {
        systemd-boot.enable = false;
        efi.canTouchEfiVariables = false;
        grub = {
          enable = true;
          efiSupport = false;
        };
      };

      systemd.network.enable = true;
      systemd.network.networks."10-wan" = {
        matchConfig.Name = "ens18";
        address = [
          "194.163.175.110/18"
          "2a02:c207:2297:7046::1/64"
        ];
        routes = [
          {Gateway = "194.163.128.1";}
          {Gateway = "fe80::1";}
        ];
        linkConfig.RequiredForOnline = "routable";
      };

      sops.secrets = {
        cloudflare_api_token_file = {
          owner = nixosConfig.config.services.caddy.user;
          group = nixosConfig.config.services.caddy.group;
        };
        r2_access_key = {
          owner = nixosConfig.config.services.niks3.user;
          group = nixosConfig.config.services.niks3.group;
        };
        r2_secret_key = {
          owner = nixosConfig.config.services.niks3.user;
          group = nixosConfig.config.services.niks3.group;
        };
        niks3_signing_key = {
          owner = nixosConfig.config.services.niks3.user;
          group = nixosConfig.config.services.niks3.group;
        };
        niks3_auth_token = {
          owner = nixosConfig.config.services.niks3.user;
          group = nixosConfig.config.services.niks3.group;
        };
      };

      services.openssh.enable = true;

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

      services.fail2ban = {
        enable = true;
        jails = {
          caddyaccess.settings = {
            filter = "caddy-access";
            logpath = "/var/log/niks3.jadestar.dev/access.log";
            port = "http,https";
            maxretry = 5;
            findtime = 30;
            bantime = 600;
          };
        };
      };

      environment.etc."fail2ban/filter.d/caddy-access.conf".text = pkgs.lib.mkDefault (pkgs.lib.mkAfter ''
        [Definition]
        failregex = ^<HOST>.*"(GET|POST|OPTION).*" (4[0-9][0-9])[ \d]*$
        ignoreregex =
      '');
    };
  };
}
