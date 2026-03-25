{
  unify.hosts.nixos.aesop.nixos = {
    networking.firewall.allowedTCPPorts = [2586];

    services.ntfy-sh = {
      enable = true;
      settings = {
        base-url = "https://ntfy.jadestar.dev";
        listen-http = ":2586";
        behind-proxy = true;
        auth-default-access = "deny-all";
        auth-users = [
          "jellyseerr:$2a$12$9F0eH3eeGPPU5jMQwrCuGOgvIN067RrQLYRBnmD7TmwrXy/YImJUC:user"
          "jaden:$2a$10$tqT6pZQ.XnBHBQL5hP3ucOMQUk5xiCUHjXCdVD3Qexhg6U5P7VKnC:user"
        ];
        auth-access = [
          "jellyseerr:jellyseerr:rw"
          "jaden:jellyseerr:ro"
        ];
      };
    };
  };
}
