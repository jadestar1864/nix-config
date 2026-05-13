{lib, ...}: {
  den.default.nixos = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      efivar
      efibootmgr
    ];
    boot = {
      initrd.systemd.enable = true;
      loader = {
        systemd-boot.enable = lib.mkDefault true;
        efi.canTouchEfiVariables = lib.mkDefault true;
        timeout = 3;
      };
    };
  };
}
