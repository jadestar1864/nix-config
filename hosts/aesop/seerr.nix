{
  den.aspects.aesop.nixos = {
    services.jellyseerr = {
      enable = true;
      openFirewall = true;
    };
  };
}
