{
  unify.hosts.nixos.dokja.nixos = {
    config,
    lib,
    ...
  }: {
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

    # Declarative nginx server blocks - dynamically load all .conf files
    # Each nginx config file is in a separate file in this directory
    systemd.tmpfiles.settings."10-swag-site-confs" = let
      configFiles = builtins.attrNames (builtins.readDir ./swag-configs);
      confFiles = builtins.filter (name: lib.hasSuffix ".conf" name) configFiles;
    in
      builtins.listToAttrs (map (file: {
          name = "/swag/nginx/proxy-confs/${file}";
          value = {
            f = {
              user = "swag";
              group = "swag";
              mode = "0644";
              argument = builtins.readFile ./swag-configs/${file};
            };
          };
        })
        confFiles);

    networking.firewall.allowedTCPPorts = [80 443];

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
          SUBDOMAINS = "wildcard";
          VALIDATION = "dns";
          DNSPLUGIN = "cloudflare";
          ONLY_SUBDOMAINS = "true";
          EXTRA_DOMAINS = "*.jellyfin.jadestar.dev";
          PROPAGATION = "30";
        };
      };
    };
  };
}
