{
  flake.modules.homeManager.gui = {pkgs, ...}: {
    home.packages = with pkgs; [
      element-desktop
      protonmail-desktop
      signal-desktop
      webcord
    ];
  };
}
