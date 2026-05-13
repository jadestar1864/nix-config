{den, ...}: {
  den.hosts.x86_64-linux.dokja = {
    hostName = "dokja";
    users = {
      admin = {};
      jaden = {};
    };
    disk-layout = {
      disk0 = "/dev/vda";
      enableSwap = true;
      swapSize = 2048;
    };
  };
  den.aspects.dokja = {
    includes = with den.aspects; [
      disk-layout._.gpt-bios-compat
      auto-upgrade
    ];
    nixos = {
      hardware.facter.reportPath = ./facter.json;
      networking = {
        networkmanager.enable = false;
        useDHCP = false;
        nameservers = [
          "9.9.9.9"
          "149.112.112.112"
          "1.1.1.1"
          "1.0.0.1"
        ];
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
      users.users = {
        jaden.openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPOfH1O4AqStjq+hdCNSko0DzupT+0GeUnW7Zx7IFerc"
        ];
        admin.openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILB398NyGF03Sf811vdV0WtCPnAR1vwmCti2iqoMMJI3"
        ];
      };
    };
  };
}
