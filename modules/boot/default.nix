{lib, ...}: {
  unify = {
    nixos.boot = {
      initrd.systemd.enable = true;
      loader = {
        systemd-boot.enable = lib.mkDefault true;
        efi.canTouchEfiVariables = lib.mkDefault true;
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
