{
  unify.hosts.nixos.dokja.nixos = {
    pkgs,
    lib,
    ...
  }: let
    domains = [
      "niks3.jadestar.dev"
      "ntfy.jadestar.dev"
      "jellyfin.jadestar.dev"
      "wizarr.jellyfin.jadestar.dev"
      "seerr.jellyfin.jadestar.dev"
    ];
  in {
    services.fail2ban = {
      enable = true;
      jails =
        {
          niks3-caddyaccess.settings = {
            filter = "caddy-access";
            logpath = "/var/log/niks3.jadestar.dev/access.log";
            port = "http,https";
            maxretry = 5;
            findtime = 30;
            bantime = 600;
          };
        }
        // (lib.listToAttrs (map (elem: {
            name = "${elem}-caddyaccess";
            value = {
              settings = {
                filter = "caddy-access";
                logpath = "/var/log/${elem}/access.log";
                port = "http,https";
                maxretry = 5;
                findtime = 30;
                bantime = 600;
              };
            };
          })
          domains));
    };

    environment.etc."fail2ban/filter.d/caddy-access.conf".text = pkgs.lib.mkDefault (pkgs.lib.mkAfter ''
      [Definition]
      failregex = ^<HOST>.*"(GET|POST|OPTION).*" (4[0-9][0-9])[ \d]*$
      ignoreregex =
    '');

    systemd.tmpfiles.settings."10-caddy-logs" = lib.listToAttrs (map (elem: {
        name = "/var/log/${elem}";
        value = {
          d = {
            user = "caddy";
            group = "caddy";
            mode = "0755";
          };
        };
      })
      domains);
  };
}
