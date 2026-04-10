{
  unify.hosts.nixos.aesop.nixos = {
    pkgs,
    lib,
    ...
  }: {
    networking.firewall.interfaces.wg0.allowedTCPPorts = [37888];

    boot.kernel.sysctl = {
      "vm.nr_hugepages" = 3072;
    };

    systemd.services.p2pool = {
      enable = true;
      description = "P2Pool Mini";
      after = ["network-online.target"];
      requires = ["network-online.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        StateDirectory = "p2pool";
        StateDirectoryMode = "0700";
        WorkingDirectory = "/var/lib/p2pool";
        Restart = "on-failure";
        RestartSec = 5;
        ExecStart = ''
          ${lib.getExe pkgs.p2pool} \
            --mini \
            --host 10.169.0.3 \
            --rpc-port 18089 \
            --wallet 45AnD46ULu7RqEYzD8YaymjU77rWkDVWghZ5hNZf5Pdz7UQc7tQMYuxbH5xGP1NqoMXE2bF4Se5sJMvwMGFAerE8M36C1VB
        '';
      };
    };

    services.xmrig = {
      enable = true;
      settings = {
        autosave = true;
        cpu = {
          enabled = true;
          priority = 1;
        };
        cuda = false;
        opencl = false;
        pools = [
          {
            url = "127.0.0.1:3333";
          }
        ];
      };
    };

    systemd.services.xmrig.after = ["p2pool.service"];
  };
}
