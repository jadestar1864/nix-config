{
  unify.hosts.nixos.teemo.nixos = {
    config,
    pkgs,
    ...
  }: {
    sops.secrets.pcloud_access_token = {};
    sops.templates.rclone-space_file = {
      owner = "silverbullet";
      group = "silverbullet";
      content = ''
        [remote-notes]
        type = pcloud
        hostname = api.pcloud.com
        token = {"access_token":"${config.sops.placeholder.pcloud_access_token}","token_type":"bearer","expiry":"0001-01-01T00:00:00Z"}
      '';
    };

    environment.systemPackages = [pkgs.rclone];
    fileSystems."/space" = {
      device = "remote-notes:/notes";
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
        "uid=${toString config.users.users.silverbullet.uid}"
        "gid=${toString config.users.groups.silverbullet.gid}"
      ];
    };
  };
}
