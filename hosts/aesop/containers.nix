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
      "nzbget"
    ];
    mediaFolders = [
      "Movies"
      "Music"
      "Shows"
    ];
  in {
    sops.secrets = {
      gluetun_env = {};
      qbittorrent_env = {};
      nzbget_env = {};
    };

    sops.templates = {
      gluetun_env_file.content = ''
        ${config.sops.placeholder.gluetun_env}
      '';
      qbittorrent_env_file.content = ''
        PUID=${toString config.users.users.qbittorrent.uid}
        PGID=${toString config.users.groups.qbittorrent.gid}
        ${config.sops.placeholder.qbittorrent_env}
      '';
      nzbget_env_file.content = ''
        ${config.sops.placeholder.nzbget_env}
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
          "/media:/media"
        ];
        ports = [
          "8096:8096"
          "5690:5690" # for wizarr on same container network
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
          "13060:13060"
          "6789:6789"
        ];
        volumes = [
          "/var/lib/gluetun:/gluetun"
        ];
      };
      qbittorrent = {
        image = "ghcr.io/linuxserver/qbittorrent";
        pull = "newer";
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
        dependsOn = ["gluetun"];
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
        dependsOn = ["gluetun"];
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
          "/media/Shows:/shows"
          "/qbittorrent-downloads:/downloads"
        ];
        networks = ["container:gluetun"];
        dependsOn = ["qbittorrent"];
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
          "/media/Movies:/movies"
          "/qbittorrent-downloads:/downloads"
        ];
        networks = ["container:gluetun"];
        dependsOn = ["qbittorrent"];
      };
      wizarr = {
        image = "ghcr.io/wizarrrr/wizarr";
        pull = "newer";
        networks = ["container:jellyfin"];
        environment =
          linuxserverUser "wizarr"
          // {
            TZ = "America/Chicago";
          };
        volumes = [
          "/var/lib/wizarr:/data"
        ];
      };
      nzbget = {
        image = "ghcr.io/linuxserver/nzbget";
        pull = "newer";
        environment =
          (linuxserverUser "nzbget")
          // {
            TZ = "America/Chicago";
          };
        environmentFiles = [
          config.sops.templates.nzbget_env_file.path
        ];
        volumes = [
          "/var/lib/nzbget:/config"
          "/nzbget-downloads:/downloads"
        ];
        networks = ["container:gluetun"];
        dependsOn = ["gluetun"];
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
          name = "/qbittorrent-downloads/complete";
          value = {
            d = {
              user = toString config.users.users.qbittorrent.uid;
              group = toString config.users.groups.media.gid;
              mode = "0775";
            };
          };
        }
        {
          name = "/qbittorrent-downloads/incomplete";
          value = {
            d = {
              user = toString config.users.users.qbittorrent.uid;
              group = toString config.users.groups.media.gid;
              mode = "0775";
            };
          };
        }
        {
          name = "/nzbget-downloads";
          value = {
            d = {
              user = toString config.users.users.nzbget.uid;
              group = toString config.users.groups.media.gid;
              mode = "0775";
            };
          };
        }
        {
          name = "/nzbget-downloads/complete";
          value = {
            d = {
              user = toString config.users.users.nzbget.uid;
              group = toString config.users.groups.media.gid;
              mode = "0775";
            };
          };
        }
        {
          name = "/nzbget-downloads/intermediate";
          value = {
            d = {
              user = toString config.users.users.nzbget.uid;
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
            name = "/media/${elem}";
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
