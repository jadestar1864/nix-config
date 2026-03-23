{
  unify.hosts.nixos.teemo.nixos = {config, ...}: {
    # SOPS secret for SWAG ACME certificate management
    sops.secrets.cloudflare_api_token_file = {
      owner = "swag";
      group = "swag";
    };

    users = {
      users.swag = {
        uid = 10000;
        group = "swag";
        isSystemUser = true;
        home = "/data-home/swag";
        createHome = true;
        linger = true;
      };
      groups.swag.gid = 10000;
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
      "/swag/nginx/site-confs/actual.subdomain.conf" = {
        f = {
          user = "swag";
          group = "swag";
          mode = "0644";
          argument = builtins.readFile ./swag-configs/actual.subdomain.conf;
        };
      };
      "/swag/nginx/site-confs/notes.subdomain.conf" = {
        f = {
          user = "swag";
          group = "swag";
          mode = "0644";
          argument = builtins.readFile ./swag-configs/notes.subdomain.conf;
        };
      };
      "/swag/nginx/site-confs/journal.subdomain.conf" = {
        f = {
          user = "swag";
          group = "swag";
          mode = "0644";
          argument = builtins.readFile ./swag-configs/journal.subdomain.conf;
        };
      };
      "/swag/nginx/site-confs/grafana.subdomain.conf" = {
        f = {
          user = "swag";
          group = "swag";
          mode = "0644";
          argument = builtins.readFile ./swag-configs/grafana.subdomain.conf;
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
          SUBDOMAINS = "actual,grafana,journal,notes";
          VALIDATION = "dns";
          DNSPLUGIN = "cloudflare";
          ONLY_SUBDOMAINS = "true";
        };
      };
    };
  };
}
