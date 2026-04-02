{
  unify.hosts.nixos.teemo.nixos = {
    config,
    pkgs,
    ...
  }: {
    sops.secrets = {
      pcloud_access_token = {};
      journal_enc_pw = {};
      journal_enc_salt = {};
    };
    sops.templates.rclone-space_file = {
      content = ''
        [remote]
        type = pcloud
        hostname = api.pcloud.com
        token = {"access_token":"${config.sops.placeholder.pcloud_access_token}","token_type":"bearer","expiry":"0001-01-01T00:00:00Z"}

        [remote-journal]
        type = crypt
        remote = remote:/journal-enc
        password = ${config.sops.placeholder.journal_enc_pw}
        password2 = ${config.sops.placeholder.journal_enc_salt}
      '';
    };

    environment.systemPackages = [pkgs.rclone];
    fileSystems = {
      "/space" = {
        device = "remote:/notes";
        fsType = "rclone";
        options = [
          "rw"
          "noauto"
          "nofail"
          "nodev"
          "_netdev"
          "x-systemd.automount"
          "allow_other"
          "args2env"
          "config=${config.sops.templates.rclone-space_file.path}"
        ];
      };
      "/my-journal" = {
        device = "remote-journal:/";
        fsType = "rclone";
        options = [
          "rw"
          "noauto"
          "nofail"
          "nodev"
          "_netdev"
          "x-systemd.automount"
          "allow_other"
          "args2env"
          "config=${config.sops.templates.rclone-space_file.path}"
        ];
      };
    };
  };
}
