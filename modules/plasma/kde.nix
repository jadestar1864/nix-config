{
  unify.modules.desktop-plasma.nixos = {pkgs, ...}: {
    services.displayManager.sddm = {
      enable = true;
      settings.General.DisplayServer = "wayland";
      wayland.enable = true;
    };
    services.desktopManager.plasma6.enable = true;
    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      discover
      konsole
      khelpcenter
      elisa
      krdp
    ];
  };
}
