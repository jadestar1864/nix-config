{
  unify.hosts.nixos.aesop.nixos = {
    sops.secrets.external_ssd_key = {
      path = "/root/external_ssd.key";
    };
    fileSystems."/data" = {
      device = "/dev/mapper/media";
      fsType = "ext4";
      options = [
        "nofail"
        "x-systemd.device-timeout=0"
      ];
    };
    environment.etc.crypttab.text = ''
      media UUID=a0ae2a60-be3f-45b6-b410-96bf0065bc30 /root/external_ssd.key nofail
    '';
  };
}
