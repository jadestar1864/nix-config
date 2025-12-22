{
  unify.hosts.nixos.teemo.nixos = {
    sops.secrets.external_ssd_key = {
      path = "/root/external_ssd.key";
    };
    environment.etc.crypttab.text = ''
      media UUID=1980-01-01-00-00-00-00 /root/external_ssd.key luks
    '';
  };
}
