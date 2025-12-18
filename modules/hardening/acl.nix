{
  unify.nixos = {
    systemd.tmpfiles.settings."restricthome"."/home/*".Z.mode = "~0700";
  };
}
