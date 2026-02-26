{
  config,
  inputs,
  ...
}: {
  unify.hosts.nixos.dokja = {
    modules = with config.unify.modules; [
      disk-gpt-bios-compat
    ];

    users.jaden.modules = config.unify.hosts.nixos.dokja.modules;

    disk-layout = {
      disk0 = "/dev/vda";
      enableSwap = true;
      swapSize = 2;
    };

    nixos = nixosConfig: {
      imports = [inputs.niks3.nixosModules.niks3];

      system.stateVersion = "25.11";
      hardware.facter.reportPath = ./facter.json;
      networking = {
        networkmanager.enable = false;
        useDHCP = false;
        hostName = "dokja";
        nameservers = [
          "9.9.9.9"
          "149.112.112.112"
          "1.1.1.1"
          "1.0.0.1"
        ];
        firewall = {
          allowedTCPPorts = [80 443];
          allowedUDPPorts = [80 443];
        };
      };

      boot.loader = {
        systemd-boot.enable = false;
        efi.canTouchEfiVariables = false;
        grub = {
          enable = true;
          efiSupport = false;
        };
      };

      systemd.network.enable = true;
      systemd.network.networks."10-wan" = {
        matchConfig.Name = "ens6";
        address = [
          "66.179.137.242/24"
        ];
        routes = [
          {Gateway = "66.179.137.1";}
        ];
        linkConfig.RequiredForOnline = "routable";
      };

      services.openssh = {
        enable = true;
        settings.LogLevel = "VERBOSE";
      };
      users.users.jaden.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPOfH1O4AqStjq+hdCNSko0DzupT+0GeUnW7Zx7IFerc"
      ];
    };
  };
}
