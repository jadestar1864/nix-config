{
  flake.modules = {
    nixos.efi.boot.loader = {
      efi = {
        efiSysMountPoint = "/efi";
        canTouchEfiVariables = true;
      };
      grub.efiSupport = true;
    };

    homeManager.base = {pkgs, ...}: {
      home.packages = [
        pkgs.efivar
        pkgs.efibootmgr
      ];
    };
  };
}
