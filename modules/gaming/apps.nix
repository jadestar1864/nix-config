{
  den.aspects.gaming.homeManager = {pkgs, ...}: {
    home.packages = with pkgs; [
      heroic
      prismlauncher
      r2modman
    ];
  };
}
