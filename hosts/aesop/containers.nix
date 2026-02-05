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
      "bazarr"
      "decluttarr"
      "profilarr"
    ];
    rootlessUsers = [
      "decluttarr"
      "jellyseerr"
      "profilarr"
      "wizarr"
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
      decluttarr_env = {
        owner = "decluttarr";
        group = "decluttarr";
      };
      cross_seed_cfg = {
        # Why the hell do I gotta put API keys in such a stupid-ass huge pseudo code/config file?
        # So many secrets littered about, I just shoved the entire THREE-HUNDRED FUCKING LINES
        # into the sops secrets.
        owner = "qbittorrent";
        group = "media";
      };
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
      users = lib.listToAttrs (lib.imap (index: elem: let
          rootless = lib.elem elem rootlessUsers;
        in {
          name = elem;
          value = {
            uid = 10000 + index;
            isSystemUser = true;
            group = elem;
            home = "/data-home/${elem}";
            createHome = true;
            linger = rootless;
            subUidRanges = lib.optionals rootless [
              {
                count = 65536;
                startUid = 100000 + 65536 * (index - 1);
              }
            ];
            subGidRanges = lib.optionals rootless [
              {
                count = 65536;
                startGid = 100000 + 65536 * (index - 1);
              }
            ];
          };
        })
        containerUsers);
    };

    networking.firewall.allowedTCPPorts = [
      5055 # jellyseerr
      5690 # wizarr
      6868 # profilarr
    ];

    virtualisation.oci-containers.containers = let
      linuxserverUser = name: {
        PUID = toString config.users.users.${name}.uid;
        PGID = toString config.users.groups.${config.users.users.${name}.group}.gid;
      };
      rootlessUser = name: "${toString config.users.users.${name}.uid}:${toString config.users.groups.${name}.gid}";
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
          "6789:6789"
          "2468:2468"
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
        ports = [
          "9696:9696"
        ];
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
        ports = [
          "8191:8191"
        ];
      };
      sonarr = {
        image = "ghcr.io/linuxserver/sonarr";
        pull = "newer";
        environment = {
          PUID = toString config.users.users.sonarr.uid;
          PGID = toString config.users.groups.media.gid;
          UMASK = "002";
          TZ = "America/Chicago";
        };
        volumes = [
          "/var/lib/sonarr:/config"
          "/data:/data"
        ];
        ports = [
          "8989:8989"
        ];
      };
      radarr = {
        image = "ghcr.io/linuxserver/radarr";
        pull = "newer";
        environment = {
          PUID = toString config.users.users.radarr.uid;
          PGID = toString config.users.groups.media.gid;
          UMASK = "002";
          TZ = "America/Chicago";
        };
        volumes = [
          "/var/lib/radarr:/config"
          "/data:/data"
        ];
        ports = [
          "7878:7878"
        ];
      };
      wizarr = {
        image = "ghcr.io/wizarrrr/wizarr";
        pull = "newer";
        # Wizarr uses `mkdir -p /etc/wizarr/wizarr_steps` which breaks starting the container as wizarr user
        # https://github.com/wizarrrr/wizarr/blob/fae3c32426440a22c24aeee7c416c8799c73d5da/docker-entrypoint.sh#L84
        #user = rootlessUser "wizarr";
        podman = {
          user = "wizarr";
          sdnotify = "healthy";
        };
        extraOptions = [
          "--health-cmd"
          "curl --fail http://localhost:5690"
          "--health-start-period=20s"
          "--health-timeout=3s"
          "--health-interval=15s"
          "--health-retries=3"
          "--add-host=host.containers.internal:host-gateway"
        ];
        ports = [
          "5690:5690"
        ];
        environment =
          (linuxserverUser "wizarr")
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
        user = rootlessUser "jellyseerr";
        podman = {
          user = "jellyseerr";
          sdnotify = "healthy";
        };
        extraOptions = [
          "--userns=keep-id"
          "--health-cmd"
          "wget --no-verbose --tries=1 --spider http://localhost:5055/api/v1/status || exit 1"
          "--health-start-period=20s"
          "--health-timeout=3s"
          "--health-interval=15s"
          "--health-retries=3"
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
      bazarr = {
        image = "ghcr.io/linuxserver/bazarr";
        pull = "newer";
        environment = {
          PUID = toString config.users.users.bazarr.uid;
          PGID = toString config.users.groups.media.gid;
          TZ = "America/Chicago";
          UMASK = "002";
        };
        volumes = [
          "/var/lib/bazarr:/config"
          "/data/media:/data/media"
        ];
        ports = [
          "6767:6767"
        ];
      };
      decluttarr = {
        image = "ghcr.io/manimatter/decluttarr:latest";
        pull = "newer";
        # Decluttarr can't enter as non-root for some reason
        # PermissionError: [Errno 13] Permission denied: '/app/logs/logs.txt'
        #user = rootlessUser "decluttarr";
        podman = {
          user = "decluttarr";
          sdnotify = "healthy";
        };
        extraOptions = [
          "--health-cmd"
          "pgrep -f main.py || exit 1"
          "--health-interval=30s"
          "--health-start-period=10s"
          "--health-timeout=5s"
          "--health-retries=3"
          "--add-host=host.containers.internal:host-gateway"
        ];
        environment =
          (linuxserverUser "decluttarr")
          // {
            TZ = "America/Chicago";
          };
        environmentFiles = [
          config.sops.secrets.decluttarr_env.path
        ];
        volumes = [
          "/var/lib/decluttarr/logs:/app/logs"
          "${./decluttarr-cfg.yml}:/app/config/config.yaml"
          "/data/media:/data/media"
        ];
        /*
        I WOULD like this to start after the dependent services, but systemd just
        gives me "Dependency failed" without any other explanation, so whatever the fuck's wrong with it
        I no longer care. Plus, decluttarr seems to constantly keep checking for the other services
        even after failing once.

        dependsOn = [
          "qbittorrent"
          "sonarr"
          "radarr"
        ];
        */
      };
      cross-seed = {
        image = "ghcr.io/cross-seed/cross-seed:6";
        pull = "newer";
        user = "${toString config.users.users.qbittorrent.uid}:${toString config.users.groups.media.gid}";
        environment = {
          TZ = "America/Chicago";
        };
        cmd = ["daemon"];
        volumes = [
          "/var/lib/cross-seed:/config"
          "${config.sops.secrets.cross_seed_cfg.path}:/config/config.js"
          "/data/qbittorrent:/data/qbittorrent"
        ];
        networks = ["container:gluetun"];
      };
      profilarr = {
        image = "santiagosayshey/profilarr";
        pull = "newer";
        # Can't directly use the --user flag since profilarr tries to create /home/apphome
        # mkdir: cannot create directory ‘/home/appuser’: Permission denied
        #user = rootlessUser "profilarr";
        podman = {
          user = "profilarr";
          sdnotify = "healthy";
        };
        extraOptions = [
          "--health-cmd"
          "curl --fail http://localhost:6868"
          "--health-start-period=20s"
          "--health-timeout=3s"
          "--health-interval=15s"
          "--health-retries=3"
          "--add-host=host.containers.internal:host-gateway"
        ];
        ports = [
          "6868:6868"
        ];
        volumes = [
          "/var/lib/profilarr:/config"
        ];
        environment =
          linuxserverUser "profilarr"
          // {
            TZ = "America/Chicago";
          };
      };
    };

    systemd.tmpfiles.settings."10-jellyfin-arr" = let
      aclUser = name: {
        user = toString config.users.users.${name}.uid;
        group = toString config.users.groups.${config.users.users.${name}.group}.gid;
        mode = "0755";
      };
    in
      # Maybe TODO: change this list to an attr set of folder name and subfolders
      # Perhaps cleaner
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
        {
          name = "/data/qbittorrent/links";
          value = {
            d = {
              user = toString config.users.users.qbittorrent.uid;
              group = toString config.users.groups.media.gid;
              mode = "0775";
            };
          };
        }
        {
          name = "/var/lib/cross-seed";
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
        {
          name = "/var/lib/decluttarr/logs";
          value = {
            d = aclUser "decluttarr";
          };
        }
      ]);
  };
}
