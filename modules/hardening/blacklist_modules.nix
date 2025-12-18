{
  unify.nixos = {
    boot.extraModprobeConfig = ''
      install dccp /bin/true
      install sctp /bin/true
    '';
  };
}
