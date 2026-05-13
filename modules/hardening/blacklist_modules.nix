{
  den.default.nixos.boot.extraModprobeConfig = ''
    install dccp /bin/true
    install sctp /bin/true
  '';
}
