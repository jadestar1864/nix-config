{
  unify.hosts.nixos.dokja.nixos = {config, ...}: {
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
          # TODO: Provide SWAG reverse proxy confs declaratively
          # Currently placed in directory imperatively
          # Fails with symlink because s6 can't change permissions on the confs I think
          #"${./swag-proxy-confs}:/config/nginx/proxy-confs"
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
        };
      };
    };
  };
}
