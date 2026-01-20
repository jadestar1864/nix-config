{
  unify.hosts.nixos.teemo.nixos = {config, ...}: {
    sops.secrets = {
      silverbullet_user = {};
    };
    sops.templates.silverbullet_env_file = {
      owner = "silverbullet";
      group = "silverbullet";
      content = ''
        SB_USER=${config.sops.placeholder.silverbullet_user}
      '';
    };

    users = {
      users = {
        silverbullet = {
          isSystemUser = true;
          uid = 10002;
          group = "silverbullet";
          linger = true;
          home = "/data-home/silverbullet";
          createHome = true;
          subUidRanges = [
            {
              count = 65536;
              startUid = 165536;
            }
          ];
          subGidRanges = [
            {
              count = 65536;
              startGid = 165536;
            }
          ];
        };
      };
      groups = {
        silverbullet.gid = 10002;
      };
    };

    networking.firewall.allowedTCPPorts = [
      5006 # actual
      3000 # silverbullet
    ];

    virtualisation.oci-containers.containers = {
      actual = {
        image = "actualbudget/actual-server:latest";
        pull = "newer";
        environment = {
          ACTUAL_LOGIN_METHOD = "password";
          ACTUAL_ALLOWED_LOGIN_METHODS = "password";
        };
        volumes = [
          "/actual:/data"
        ];
        ports = [
          "5006:5006"
        ];
      };
      silverbullet = {
        image = "ghcr.io/silverbulletmd/silverbullet:latest";
        pull = "newer";
        user = "silverbullet:silverbullet";
        podman = {
          user = "silverbullet";
          sdnotify = "healthy";
        };
        extraOptions = [
          "--userns=keep-id"
          "--health-cmd"
          "curl --fail http://localhost:3000/.ping || exit 1"
          "--health-timeout=3s"
          "--health-interval=15s"
          "--health-retries=3"
        ];
        environmentFiles = [
          config.sops.templates.silverbullet_env_file.path
        ];
        volumes = [
          "/data-home/silverbullet/space:/space"
        ];
        ports = [
          "3000:3000"
        ];
      };
    };

    systemd.tmpfiles.settings."10-container-data" = {
      "/data-home/silverbullet/space" = {
        d = {
          mode = "0700";
          user = "silverbullet";
          group = "silverbullet";
        };
      };
    };
  };
}
