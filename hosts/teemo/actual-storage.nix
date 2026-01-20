{
  unify.hosts.nixos.teemo.nixos = {
    sops.secrets.actual_key = {
      format = "binary";
      sopsFile = ./actual.key;
      path = "/root/actual.key";
    };

    fileSystems."/actual" = {
      device = "/dev/mapper/actual";
      fsType = "ext4";
      options = [
        "nofail"
        "x-systemd.device-timeout=0"
      ];
    };
    environment.etc.crypttab.text = ''
      actual UUID=5b979024-2a8e-4de0-964b-1b2e93459f1e /root/actual.key nofail
    '';
  };
}
