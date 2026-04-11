{
  unify.hosts.nixos.dokja.nixos = {config, ...}: {
    sops.secrets.tinyauth_env_file = {
      owner = "tinyauth";
      group = "tinyauth";
    };

    users = {
      users.tinyauth = {
        uid = 10001;
        isSystemUser = true;
        group = "tinyauth";
        linger = true;
        home = "/data-home/tinyauth";
        createHome = true;
        subUidRanges = [
          {
            count = 65536;
            startUid = 110000;
          }
        ];
        subGidRanges = [
          {
            count = 65536;
            startGid = 110000;
          }
        ];
      };
      groups.tinyauth = {};
    };

    virtualisation.oci-containers.containers = {
      tinyauth = {
        image = "ghcr.io/steveiliop56/tinyauth:latest";
        pull = "newer";
        user = "10001:10001";
        podman = {
          user = "tinyauth";
          sdnotify = "healthy";
        };
        environment = {
          TINYAUTH_APPURL = "https://tinyauth.jadestar.dev";
          TINYAUTH_ANALYTICS_ENABLED = "false";

          TINYAUTH_APPS_SBNOTES_CONFIG_DOMAIN = "notes.jadestar.dev";
          TINYAUTH_APPS_SBNOTES_USERS_ALLOW = "soravoid";

          TINYAUTH_APPS_SBJOURNAL_CONFIG_DOMAIN = "journal.jadestar.dev";
          TINYAUTH_APPS_SBJOURNAL_USERS_ALLOW = "jaden";
        };
        environmentFiles = [
          config.sops.secrets.tinyauth_env_file.path
        ];
        volumes = [
          "./:/var/lib/tinyauth"
        ];
        ports = ["3000:3000"];
        extraOptions = [
          "--health-cmd"
          "./tinyauth healthcheck"
          "--health-start-period=20s"
          "--health-timeout=3s"
          "--health-interval=15s"
          "--health-retries=3"
        ];
      };
    };

    systemd.services.podman-tinyauth.serviceConfig = {
      StateDirectory = "tinyauth";
      StateDirectoryMode = "0700";
    };
  };
}
