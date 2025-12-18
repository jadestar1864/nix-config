{lib, ...}: {
  unify = {
    nixos.boot = {
      initrd.systemd.enable = true;
      loader = {
        systemd-boot.enable = lib.mkDefault true;
        grub.efiSupport = true;
        efi.canTouchEfiVariables = true;
        timeout = 3;
      };
    };
    home = {pkgs, ...}: {
      home.packages = with pkgs; [
        efivar
        efibootmgr
      ];
    };
  };
}
