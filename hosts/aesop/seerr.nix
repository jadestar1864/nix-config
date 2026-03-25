{
  unify.hosts.nixos.aesop.nixos = {
    services.jellyseerr = {
      enable = true;
      openFirewall = true;
    };
  };
}
