{
  unify.hosts.nixos.aesop.nixos = {
    config,
    pkgs,
    ...
  }: {
    sops.secrets.external_ssd_key = {
      path = "/root/external_ssd.key";
    };
    systemd.services.mount-media = {
      enable = true;
      wantedBy = ["multi-user.target"];
      path = with pkgs; [cryptsetup mount];
      restartIfChanged = false;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        cryptsetup luksOpen --key-file "${config.sops.secrets.external_ssd_key.path}" /dev/disk/by-uuid/a0ae2a60-be3f-45b6-b410-96bf0065bc30 media
        mount /dev/mapper/media /media
      '';
    };
  };
}
