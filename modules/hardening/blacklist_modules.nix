{
  flake.modules.nixos.hardening = {
    boot.extraModprobeConfig = ''
      install dccp /bin/true
      install sctp /bin/true
    '';
  };
}
