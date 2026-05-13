{
  den.aspects.pc.homeManager = {pkgs, ...}: {
    home.packages = with pkgs; [
      freetube
    ];
  };
}
