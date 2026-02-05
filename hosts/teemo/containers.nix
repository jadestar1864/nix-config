{
  unify.hosts.nixos.teemo.nixos = {config, ...}: {
    sops.secrets = {
      silverbullet_env_file = {
        owner = "silverbullet";
        group = "silverbullet";
      };
      silverbullet_journal_env_file = {
        owner = "silverbullet";
        group = "silverbullet";
      };
    };

    users = {
      users = {
        silverbullet = {
          isSystemUser = true;
          uid = 10002;
          group = "silverbullet";
        };
      };
      groups = {
        silverbullet.gid = 10002;
      };
    };

    networking.firewall.allowedTCPPorts = [
      5006 # actual
      3000 # silverbullet
      3050 # silverbullet-journal
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
        podman = {
          sdnotify = "healthy";
        };
        extraOptions = [
          "--health-cmd"
          "curl --fail http://localhost:3000/.ping || exit 1"
          "--health-timeout=3s"
          "--health-interval=15s"
          "--health-retries=3"
        ];
        environmentFiles = [
          config.sops.secrets.silverbullet_env_file.path
        ];
        volumes = [
          "/space:/space"
        ];
        ports = [
          "3000:3000"
        ];
      };
      silverbullet-journal = {
        image = "ghcr.io/silverbulletmd/silverbullet:latest";
        pull = "newer";
        podman = {
          sdnotify = "healthy";
        };
        extraOptions = [
          "--health-cmd"
          "curl --fail http://localhost:3000/.ping || exit 1"
          "--health-timeout=3s"
          "--health-interval=15s"
          "--health-retries=3"
        ];
        environmentFiles = [
          config.sops.secrets.silverbullet_journal_env_file.path
        ];
        volumes = [
          "/my-journal:/space"
        ];
        ports = [
          "3050:3000"
        ];
      };
    };

    systemd.tmpfiles.settings."10-container-data" = {
      "/space" = {
        d = {
          mode = "0700";
          user = "silverbullet";
          group = "silverbullet";
        };
      };
      "/my-journal" = {
        d = {
          mode = "0700";
          user = "silverbullet";
          group = "silverbullet";
        };
      };
    };
  };
}
