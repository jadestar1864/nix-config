{
  unify.hosts.nixos.dokja.nixos = {pkgs, ...}: {
    services.fail2ban = {
      enable = true;
      jails = {
        niks3-caddyaccess.settings = {
          filter = "caddy-access";
          logpath = "/var/log/niks3.jadestar.dev/access.log";
          port = "http,https";
          maxretry = 5;
          findtime = 30;
          bantime = 600;
        };
        jellyfin-caddyaccess.settings = {
          filter = "caddy-access";
          logpath = "/var/log/jellyfin.jadestar.dev/access.log";
          port = "http,https";
          maxretry = 5;
          findtime = 30;
          bantime = 600;
        };
      };
    };

    environment.etc."fail2ban/filter.d/caddy-access.conf".text = pkgs.lib.mkDefault (pkgs.lib.mkAfter ''
      [Definition]
      failregex = ^<HOST>.*"(GET|POST|OPTION).*" (4[0-9][0-9])[ \d]*$
      ignoreregex =
    '');
  };
}
