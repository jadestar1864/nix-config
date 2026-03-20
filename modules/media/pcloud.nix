{lib, ...}: {
  unify.hosts.nixos =
    lib.genAttrs [
      "asrock"
      "thinkpadx1"
    ] (_: {
      users.jaden.home = {
        config,
        pkgs,
        ...
      }: {
        sops.secrets = {
          pcloud_access_token = {};
          pcloud_vault_pass = {};
          pcloud_vault_salt = {};
        };
        sops.templates.remote-pcloud-conf = {
          path = "${config.xdg.configHome}/rclone/remote-pcloud.conf";
          content = ''
            [remote-pcloud]
            type = pcloud
            hostname = api.pcloud.com
            token = {"access_token":"${config.sops.placeholder.pcloud_access_token}","token_type":"bearer","expiry":"0001-01-01T00:00:00Z"}

            [remote-pcloud-vault]
            type = crypt
            remote = remote-pcloud:/vault
            password = ${config.sops.placeholder.pcloud_vault_pass}
            password2 = ${config.sops.placeholder.pcloud_vault_salt}
          '';
        };

        systemd.user.services.remote-pcloud-mount = {
          Unit = {
            Description = "Mount remote pcloud storage to ~/Documents/Pcloud";
            After = ["network-online.target"];
          };
          Service = {
            Type = "notify";
            ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/Documents/Pcloud";
            ExecStart = "${pkgs.rclone}/bin/rclone --config=%h/.config/rclone/remote-pcloud.conf --vfs-cache-mode writes --ignore-checksum mount \"remote-pcloud:\" \"%h/Documents/Pcloud\"";
            ExecStop = "/run/wrappers/bin/fusermount -u %h/Documents/Pcloud/%i";
          };
          Install.WantedBy = ["default.target"];
        };

        systemd.user.services.remote-pcloud-vault-mount = {
          Unit = {
            Description = "Mount remote pcloud vault storage to ~/Documents/Pcloud-Vault";
            After = ["network-online.target"];
          };
          Service = {
            Type = "notify";
            ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/Documents/Pcloud-Vault";
            ExecStart = "${pkgs.rclone}/bin/rclone --config=%h/.config/rclone/remote-pcloud.conf --vfs-cache-mode writes --ignore-checksum mount \"remote-pcloud-vault:\" \"%h/Documents/Pcloud-Vault\"";
            ExecStop = "/run/wrappers/bin/fusermount -u %h/Documents/Pcloud-Vault/%i";
          };
          Install.WantedBy = ["default.target"];
        };
      };
    });
}
