{
  unify.modules.pc.nixos = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      yubioath-flutter
      yubikey-manager
    ];

    # Yubikey required services and config. See Dr. Duh NixOS config for reference
    services.pcscd.enable = true;
    services.udev.packages = [pkgs.yubikey-personalization];
  };
}
