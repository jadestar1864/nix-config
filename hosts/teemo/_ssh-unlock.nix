{
  unify.hosts.nixos.teemo.nixos = {pkgs, ...}: {
    sops.secrets.initrd_ssh_private_key = {};

    boot.kernelParams = ["ip=192.168.1.3::192.168.1.254:255.255.255.0:teemo::none"];
    boot.initrd = {
      availableKernelModules = [
        #
        # ========== Network Kernel Modules ==========
        #
        "wireguard"
        "genet"
        "brcmfmac"

        #
        # ========== LUKS and Encryption Kernel Modules ==========
        #
        "algif_skcipher"
        "xchacha20"
        "adiantum"
        "aes_neon_bs"
        "sha256"
        "nhpoly1305"
        "dm-crypt"
      ];

      network = {
        enable = true;
        ssh = {
          enable = true;
          port = 2222;
          hostKeys = [
            #config.sops.secrets.initrd_ssh_private_key.path
            ../../init
          ];
          authorizedKeys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGR32T6U1UaFiqWYuu3LBd0JuN98N99ThLyOlRiJQsdJ "
          ];
        };
      };

      secrets = {
        #"/etc/secrets/30-wg-initrd.key" = config.sops.secrets.wg_private_key.path;
        "/etc/secrets/30-wg-initrd.key" = ../../wg;
        #"/etc/secrets/30-wg-initrd-psk.key" = config.sops.secrets.wg_preshared_key.path;
        "/etc/secrets/30-wg-initrd-psk.key" = ../../wgpsk;
      };

      systemd = {
        #users.root.shell = "/bin/systemd-tty-ask-password-agent";
        network = {
          netdevs."30-wg-initrd" = {
            netdevConfig = {
              Kind = "wireguard";
              Name = "wg-initrd";
            };
            wireguardConfig = {PrivateKeyFile = "/etc/secrets/30-wg-initrd.key";};
            wireguardPeers = [
              {
                PublicKey = "pCwHRFMru2N8Gh/P3KZKcVdiOoqLFwJh3tKve/j8DwY=";
                PresharedKeyFile = "/etc/secrets/30-wg-initrd-psk.key";
                AllowedIPs = [
                  "fd31:bf08:57cb::7/128"
                  "10.169.0.1/32"
                ];
                Endpoint = "194.163.175.110:51820";
                PersistentKeepalive = 25;
              }
            ];
          };
          networks."30-wg-initrd" = {
            name = "wg-initrd";
            address = [
              "fd31:bf08:57cb::9/128"
              "10.169.0.3/32"
            ];
          };
        };

        services.ntpdate-sync = {
          wantedBy = ["initrd.target"];
          after = ["systemd-networkd.service"];
          path = [pkgs.ntp];
          serviceConfig.type = "oneshot";
          script = ''
            echo "ntp: starting ntpdate"
            echo "ntp   123/tcp" >> /etc/services
            echo "ntp   123/udp" >> /etc/services
            ntpdate pool.ntp.org
          '';
        };
      };
    };
  };
}
