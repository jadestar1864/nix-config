{
  unify.modules.pc.home = {pkgs, ...}: {
    home.packages = with pkgs; [
      freetube
    ];
  };
}
