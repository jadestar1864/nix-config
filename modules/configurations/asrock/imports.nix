{config, ...}: {
  configurations.nixos.asrock.module = {
    imports = with config.flake.modules.nixos; [
      disk-btrfs-on-luks-with-raid0
      efi
      systemd-boot
      pc
      dev
      gaming

      desktop-plasma
    ];
  };
}
