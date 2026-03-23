{
  unify.hosts.nixos.aesop.nixos = {config, ...}: {
    # SOPS secret for SWAG ACME certificate management
    sops.secrets.cloudflare_api_token_file = {
      owner = "swag";
      group = "swag";
    };

    users = {
      # Use UID 10032 to avoid collision with container users (10000-10011) from containers.nix
      # Teemo's swag uses UID 10000 (no collision there)
      users.swag = {
        uid = 10032;
        group = "swag";
        isSystemUser = true;
        home = "/data-home/swag";
        createHome = true;
        linger = true;
      };
      groups.swag.gid = 10032;
    };

    systemd.tmpfiles.settings."10-swag" = {
      "/swag" = {
        d = {
          user = "swag";
          group = "swag";
          mode = "0755";
        };
      };
      "/swag/nginx/site-confs" = {
        d = {
          user = "swag";
          group = "swag";
          mode = "0755";
        };
      };
    };

    # Declarative nginx server blocks - use builtins.readFile for clarity
    # Each nginx config file is in a separate file in this directory
    systemd.tmpfiles.settings."10-swag-site-confs" = {
      "/swag/nginx/site-confs/jellyfin.subdomain.conf" = {
        f = {
          user = "swag";
          group = "swag";
          mode = "0644";
          argument = builtins.readFile ./swag-configs/jellyfin.subdomain.conf;
        };
      };
      "/swag/nginx/site-confs/seerr.subdomain.conf" = {
        f = {
          user = "swag";
          group = "swag";
          mode = "0644";
          argument = builtins.readFile ./swag-configs/seerr.subdomain.conf;
        };
      };
      "/swag/nginx/site-confs/wizarr.subdomain.conf" = {
        f = {
          user = "swag";
          group = "swag";
          mode = "0644";
          argument = builtins.readFile ./swag-configs/wizarr.subdomain.conf;
        };
      };
      "/swag/nginx/site-confs/ntfy.subdomain.conf" = {
        f = {
          user = "swag";
          group = "swag";
          mode = "0644";
          argument = builtins.readFile ./swag-configs/ntfy.subdomain.conf;
        };
      };
      "/swag/nginx/site-confs/bazarr.subdomain.conf" = {
        f = {
          user = "swag";
          group = "swag";
          mode = "0644";
          argument = builtins.readFile ./swag-configs/bazarr.subdomain.conf;
        };
      };
      "/swag/nginx/site-confs/sonarr.subdomain.conf" = {
        f = {
          user = "swag";
          group = "swag";
          mode = "0644";
          argument = builtins.readFile ./swag-configs/sonarr.subdomain.conf;
        };
      };
      "/swag/nginx/site-confs/radarr.subdomain.conf" = {
        f = {
          user = "swag";
          group = "swag";
          mode = "0644";
          argument = builtins.readFile ./swag-configs/radarr.subdomain.conf;
        };
      };
      "/swag/nginx/site-confs/prowlarr.subdomain.conf" = {
        f = {
          user = "swag";
          group = "swag";
          mode = "0644";
          argument = builtins.readFile ./swag-configs/prowlarr.subdomain.conf;
        };
      };
    };

    virtualisation.oci-containers.containers = {
      swag = {
        image = "lscr.io/linuxserver/swag:latest";
        pull = "newer";
        capabilities = {
          NET_ADMIN = true;
        };
        volumes = [
          "/swag:/config"
          "${config.sops.secrets.cloudflare_api_token_file.path}:/config/dns-conf/cloudflare.ini"
        ];
        extraOptions = ["--network=host"];
        environment = {
          PUID = toString config.users.users.swag.uid;
          PGID = toString config.users.groups.swag.gid;
          TZ = "America/Chicago";
          URL = "jadestar.dev";
          SUBDOMAINS = "bazarr,sonarr,radarr,prowlarr,seerr,wizarr,ntfy";
          VALIDATION = "dns";
          DNSPLUGIN = "cloudflare";
          ONLY_SUBDOMAINS = "true";
        };
      };
    };
  };
}
