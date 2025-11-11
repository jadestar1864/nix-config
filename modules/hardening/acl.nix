{
  flake.nixos.modules.hardening = {
    systemd.tmpfiles.settings."restricthome"."/home/*".Z.mode = "~0700";
  };
}
