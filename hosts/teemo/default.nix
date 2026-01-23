{
  config,
  inputs,
  ...
}: {
  # Using https://github.com/pftf/RPi4 @ v1.50
  unify.hosts.nixos.teemo = {
    modules = with config.unify.modules; [
      disk-ext4-simple
    ];

    users.jaden.modules = config.unify.hosts.nixos.teemo.modules;

    disk-layout = {
      disk0 = "/dev/disk/by-id/usb-USB_SanDisk_3.2Gen1_03020405050625094732-0:0";
      enableSwap = true;
      swapSize = 4;
    };

    nixos = {
      pkgs,
      lib,
      modulesPath,
      ...
    }: {
      imports = [
        inputs.nixos-hardware.nixosModules.raspberry-pi-4
        "${modulesPath}/profiles/minimal.nix"
      ];

      boot = {
        loader = {
          generic-extlinux-compatible.enable = false;
          efi.canTouchEfiVariables = false;
        };
        kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
        # Needed with the USB stick I have
        initrd.availableKernelModules = ["uas"];
        blacklistedKernelModules = [
          # Disable wifi
          "brcmfmac"
          "brcmutil"
          # Disable bluetooth
          "btbmc"
          "hci_uart"
        ];
        # Faster ciphers on rpi
        kernelModules = [
          "xchacha20"
          "adiantum"
          "nhpoly1305"
        ];
        kernelParams = [
          "console=ttyS0,115200n8"
          "console=ttyAMA0,115200n8"
          "console=tty0"
        ];
      };
      environment.systemPackages = with pkgs; [
        libraspberrypi
        raspberrypi-eeprom
      ];

      services.openssh.enable = true;
      users.users.jaden.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFHZOOvZpYbDpCTbYlFXlG6nQiS88LV4Nak8hoJsTl8u"
      ];

      # TODO: Use NTS on teemo
      # chrony will fail if time is too far offset on boot
      services.chrony.enable = lib.mkForce false;
      services.timesyncd.enable = lib.mkForce true;
      # RPi has no RTC
      # services.chrony.extraFlags = ["-s"];
      services.usbguard.enable = false;

      powerManagement.cpuFreqGovernor = "ondemand";

      system.stateVersion = "25.11";
      hardware.facter.reportPath = ./facter.json;
      networking = {
        networkmanager.enable = false;
        useDHCP = false;
        hostName = "teemo";
      };

      systemd.network.enable = true;
      systemd.network.networks."10-wan" = {
        matchConfig.Name = "end0";
        address = ["192.168.1.3/24"];
        routes = [
          {Gateway = "192.168.1.254";}
        ];
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };
}
