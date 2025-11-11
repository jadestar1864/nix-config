{config, ...}: {
  configurations.nixos.thinkpadx1.module = {
    imports = with config.flake.modules.nixos; [
      disk-btrfs-on-luks
      efi
      systemd-boot
      pc
      dev
      hardening

      desktop-plasma
      laptop
    ];
  };
}
