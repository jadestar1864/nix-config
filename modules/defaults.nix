{
  den,
  lib,
  ...
}: {
  den.default = {
    nixos.system.stateVersion = "25.11";
    homeManager.home.stateVersion = "25.11";
    includes = [
      den.batteries.define-user
      den.batteries.hostname
      den.batteries.inputs'
    ];
  };

  den.schema.user.classes = lib.mkDefault ["homeManager"];
  den.schema.user.includes = [
    den.batteries.host-aspects
    den.batteries.mutual-provider
  ];
}
