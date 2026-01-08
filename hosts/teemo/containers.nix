{
  unify.hosts.nixos.teemo.nixos = {
    config,
    lib,
    ...
  }: let
  in {
    sops.secrets = {
      gluetun_env = {};
      qbittorrent_env = {};
    };

    sops.templates = {
      gluetun_env_file.content = ''
        PUID=${toString config.users.users.gluetun.uid}
        PGID=${toString config.users.groups.gluetun.gid}
        ${config.sops.placeholder.gluetun_env}
      '';
      qbittorrent_env_file.content = ''
        PUID=${toString config.users.users.qbittorrent.uid}
        PGID=${toString config.users.groups.qbittorrent.gid}
        ${config.sops.placeholder.qbittorrent_env}
      '';
    };

    # UIDs and GIDs are hardcoded so we can reference them elsewhere
    users = let
      # Changing the order will probably break a lot of things on an existing system
      containerUsers = [
        "jellyfin"
        "gluetun"
        "qbittorrent"
        "prowlarr"
        "flaresolverr"
        "sonarr"
        "radarr"
      ];
    in {
      groups = lib.listToAttrs ((lib.imap (index: elem: {
            name = elem;
            value = {gid = 10000 + index;};
          })
          containerUsers)
        ++ [
          {
            name = "media";
            value = {gid = 10000;};
          }
        ]);
      users = lib.listToAttrs (lib.imap (index: elem: {
          name = elem;
          value = {
            uid = 10000 + index;
            isSystemUser = true;
            group = elem;
          };
        })
        containerUsers);
    };

    virtualisation.oci-containers.containers = let
      dockerUser = name: {
        PUID = toString config.users.users.${name}.uid;
        PGID = toString config.users.groups.${config.users.users.${name}.group}.gid;
      };
    in {
      jellyfin = {
        image = "ghcr.io/linuxserver/jellyfin";
        environment = dockerUser "jellyfin";
        volumes = [
          "/var/lib/jellyfin:/config"
          "/media:/media"
        ];
        ports = [
          "8096:8096"
        ];
      };
      gluetun = {
        image = "qmcgaw/gluetun";
        capabilities = {
          NET_ADMIN = true;
          NET_RAW = true;
        };
        environmentFiles = [
          config.sops.templates.gluetun_env_file.path
        ];
        devices = ["/dev/net/tun:/dev/net/tun"];
        ports = [
          # Open ports from other containers routing network through gluetun
          "8080:8080"
          "9696:9696"
          "8191:8191"
          "8989:8989"
          "7878:7878"
          "13060:13060"
        ];
        volumes = [
          "/var/lib/gluetun:/gluetun"
        ];
      };
      qbittorrent = {
        image = "ghcr.io/linuxserver/qbittorrent";
        environmentFiles = [
          config.sops.templates.qbittorrent_env_file.path
        ];
        volumes = [
          "/var/lib/qbittorrent:/config"
          "/qbittorrent-downloads:/downloads"
        ];
        networks = ["container:gluetun"];
        dependsOn = ["gluetun"];
      };
      prowlarr = {
        image = "lscr.io/linuxserver/prowlarr:develop";
        environment =
          (dockerUser "prowlarr")
          // {
            TZ = "America/New_York";
          };
        volumes = [
          "/var/lib/prowlarr:/config"
        ];
        networks = ["container:gluetun"];
        dependsOn = ["gluetun"];
      };
      flaresolverr = {
        image = "ghcr.io/flaresolverr/flaresolverr";
        environment =
          (dockerUser "flaresolverr")
          // {
            TZ = "America/New_York";
          };
        volumes = [
          "/var/lib/flaresolverr:/config"
        ];
        networks = ["container:gluetun"];
        dependsOn = ["gluetun"];
      };
      sonarr = {
        image = "ghcr.io/linuxserver/sonarr";
        environment = {
          PUID = toString config.users.users.sonarr.uid;
          PGID = toString config.users.groups.media.gid;
          TZ = "America/New_York";
        };
        volumes = [
          "/var/lib/sonarr:/config"
          "/media/Shows:/shows"
          "/qbittorrent-downloads:/downloads"
        ];
        networks = ["container:gluetun"];
        dependsOn = ["qbittorrent"];
      };
      radarr = {
        image = "ghcr.io/linuxserver/radarr";
        environment = {
          PUID = toString config.users.users.radarr.uid;
          PGID = toString config.users.groups.media.gid;
          TZ = "America/New_York";
        };
        volumes = [
          "/var/lib/radarr:/config"
          "/media/Movies:/movies"
          "/qbittorrent-downloads:/downloads"
        ];
        networks = ["container:gluetun"];
        dependsOn = ["qbittorrent"];
      };
    };

    systemd.tmpfiles.settings."10-jellyfin-arr" = let
      aclUser = name: {
        user = toString config.users.users.${name}.uid;
        group = toString config.users.groups.${config.users.users.${name}.group}.gid;
        mode = "0755";
      };
    in
      lib.listToAttrs (lib.flatten [
        {
          name = "/qbittorrent-downloads";
          value = {
            d = {
              user = toString config.users.users.qbittorrent.uid;
              group = toString config.users.groups.media.gid;
              mode = "0775";
            };
          };
        }
        {
          name = "/media";
          value = {
            d = {
              user = toString config.users.users.jellyfin.uid;
              group = toString config.users.groups.media.gid;
              mode = "0775";
            };
          };
        }
        (map (elem: {
            name = "/var/lib/${elem}";
            value = {
              d = aclUser elem;
            };
          }) [
            "jellyfin"
            "gluetun"
            "qbittorrent"
            "prowlarr"
            "flaresolverr"
            "sonarr"
            "radarr"
          ])
      ]);
  };
}
