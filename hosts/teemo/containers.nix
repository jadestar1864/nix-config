{
  unify.hosts.nixos.teemo.nixos = {
    sops.secrets = {
      silverbullet_env_file = {};
      silverbullet_journal_env_file = {};
    };

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
        volumes = [
          "/my-journal:/space"
        ];
        ports = [
          "3050:3000"
        ];
      };
    };

    systemd.services = {
      podman-actual.unitConfig.RequiresMountsFor = ["/actual"];
      podman-silverbullet.unitConfig.RequiresMountsFor = ["/space"];
      podman-silverbullet-journal.unitConfig.RequiresMountsFor = ["/my-journal"];
    };
  };
}
