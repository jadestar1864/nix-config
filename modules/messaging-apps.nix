{
  unify.modules.pc.home = {pkgs, ...}: {
    home.packages = with pkgs; [
      element-desktop
      protonmail-desktop
      signal-desktop
      tutanota-desktop
      webcord
    ];
  };
}
