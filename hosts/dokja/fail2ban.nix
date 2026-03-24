{
  unify.hosts.nixos.dokja.nixos = {
    # Fail2ban will be enabled - default nginx jails will provide protection
    # User can configure custom jails later if needed
    services.fail2ban.enable = true;
  };
}
