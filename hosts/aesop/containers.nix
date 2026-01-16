{
  unify.hosts.nixos.aesop.nixos = {
    config,
    lib,
    ...
  }: let
    # Changing the order will probably break a lot of things on an existing system
    containerUsers = [
      "gluetun"
      "jellyfin"
      "qbittorrent"
      "prowlarr"
      "flaresolverr"
      "sonarr"
      "radarr"
      "wizarr"
      "jellyseerr"
    ];
    mediaFolders = [
      "Anime"
      "Books"
      "Movies"
      "Music"
      "Shows"
    ];
  in {
    sops.secrets = {
      gluetun_env = {};
      qbittorrent_env = {};
    };

    sops.templates = {
      gluetun_env_file.content = ''
        ${config.sops.placeholder.gluetun_env}
      '';
      qbittorrent_env_file.content = ''
        PUID=${toString config.users.users.qbittorrent.uid}
        PGID=${toString config.users.groups.media.gid}
        ${config.sops.placeholder.qbittorrent_env}
      '';
    };

    # UIDs and GIDs are hardcoded so we can reference them elsewhere
    users = {
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
      linuxserverUser = name: {
        PUID = toString config.users.users.${name}.uid;
        PGID = toString config.users.groups.${config.users.users.${name}.group}.gid;
      };
    in {
      jellyfin = {
        image = "ghcr.io/linuxserver/jellyfin";
        pull = "newer";
        environment = {
          PUID = toString config.users.users.jellyfin.uid;
          PGID = toString config.users.groups.render.gid;
          DOCKER_MODS = "linuxserver/mods:jellyfin-opencl-intel";
          JELLYFIN_PublishedServerUrl = "https://jellyfin.jadestar.dev";
        };
        devices = ["/dev/dri:/dev/dri"];
        volumes = [
          "/var/lib/jellyfin:/config"
          "/data/media:/media"
        ];
        ports = [
          "8096:8096"
        ];
      };
      gluetun = {
        image = "qmcgaw/gluetun";
        pull = "newer";
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
          "6789:6789"
        ];
        volumes = [
          "/var/lib/gluetun:/gluetun"
        ];
      };
      qbittorrent = {
        image = "ghcr.io/linuxserver/qbittorrent";
        pull = "newer";
        environment = {
          UMASK = "002";
        };
        environmentFiles = [
          config.sops.templates.qbittorrent_env_file.path
        ];
        volumes = [
          "/var/lib/qbittorrent:/config"
          "/data/qbittorrent:/data/qbittorrent"
        ];
        networks = ["container:gluetun"];
      };
      prowlarr = {
        image = "lscr.io/linuxserver/prowlarr:develop";
        pull = "newer";
        environment =
          (linuxserverUser "prowlarr")
          // {
            TZ = "America/Chicago";
          };
        volumes = [
          "/var/lib/prowlarr:/config"
        ];
        networks = ["container:gluetun"];
      };
      flaresolverr = {
        image = "ghcr.io/flaresolverr/flaresolverr";
        pull = "newer";
        environment =
          (linuxserverUser "flaresolverr")
          // {
            TZ = "America/Chicago";
          };
        volumes = [
          "/var/lib/flaresolverr:/config"
        ];
        networks = ["container:gluetun"];
      };
      sonarr = {
        image = "ghcr.io/linuxserver/sonarr";
        pull = "newer";
        environment = {
          PUID = toString config.users.users.sonarr.uid;
          PGID = toString config.users.groups.media.gid;
          TZ = "America/Chicago";
        };
        volumes = [
          "/var/lib/sonarr:/config"
          "/data:/data"
        ];
        networks = ["container:gluetun"];
      };
      radarr = {
        image = "ghcr.io/linuxserver/radarr";
        pull = "newer";
        environment = {
          PUID = toString config.users.users.radarr.uid;
          PGID = toString config.users.groups.media.gid;
          TZ = "America/Chicago";
        };
        volumes = [
          "/var/lib/radarr:/config"
          "/data:/data"
        ];
        networks = ["container:gluetun"];
      };
      wizarr = {
        image = "ghcr.io/wizarrrr/wizarr";
        pull = "newer";
        ports = [
          "5690:5690"
        ];
        environment =
          linuxserverUser "wizarr"
          // {
            TZ = "America/Chicago";
          };
        volumes = [
          "/var/lib/wizarr:/data"
        ];
      };
      jellyseerr = {
        image = "ghcr.io/fallenbagel/jellyseerr:latest";
        pull = "newer";
        user = "${toString config.users.users.jellyseerr.uid}:${toString config.users.groups.jellyseerr.gid}";
        extraOptions = [
          "--userns=keep-id"
        ];
        ports = [
          "5055:5055"
        ];
        environment = {
          PORT = "5055";
          TZ = "America/Chicago";
        };
        volumes = [
          "/var/lib/jellyseerr:/app/config"
        ];
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
          name = "/data";
          value = {
            d = aclUser "root";
          };
        }
        {
          name = "/data/qbittorrent";
          value = {
            d = {
              user = toString config.users.users.qbittorrent.uid;
              group = toString config.users.groups.media.gid;
              mode = "0775";
            };
          };
        }
        {
          name = "/data/qbittorrent/complete";
          value = {
            d = {
              user = toString config.users.users.qbittorrent.uid;
              group = toString config.users.groups.media.gid;
              mode = "0775";
            };
          };
        }
        {
          name = "/data/qbittorrent/incomplete";
          value = {
            d = {
              user = toString config.users.users.qbittorrent.uid;
              group = toString config.users.groups.media.gid;
              mode = "0775";
            };
          };
        }
        /*
        TODO: Future usenet directories
        {
          name = "/data/usenet";
          value = {
            d = {
              user = toString config.users.users.nzbget.uid;
              group = toString config.users.groups.media.gid;
              mode = "0775";
            };
          };
        }
        {
          name = "/data/usenet/complete";
          value = {
            d = {
              user = toString config.users.users.nzbget.uid;
              group = toString config.users.groups.media.gid;
              mode = "0775";
            };
          };
        }
        (map (elem: {
            name = "/data/usenet/complete/${elem}";
            value = {
              d = {
                user = toString config.users.users.nzbget.uid;
                group = toString config.users.groups.media.gid;
                mode = "0775";
              };
            };
          })
          mediaFolders)
        {
          name = "/data/usenet/intermediate";
          value = {
            d = {
              user = toString config.users.users.nzbget.uid;
              group = toString config.users.groups.media.gid;
              mode = "0775";
            };
          };
        }
        */
        {
          name = "/data/media";
          value = {
            d = {
              user = toString config.users.users.jellyfin.uid;
              group = toString config.users.groups.media.gid;
              mode = "0775";
            };
          };
        }
        (map (elem: {
            name = "/data/media/${elem}";
            value = {
              d = {
                user = toString config.users.users.jellyfin.uid;
                group = toString config.users.groups.media.gid;
                mode = "0775";
              };
            };
          })
          mediaFolders)
        (map (elem: {
            name = "/var/lib/${elem}";
            value = {
              d = aclUser elem;
            };
          })
          containerUsers)
      ]);
  };
}
