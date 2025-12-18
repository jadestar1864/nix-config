{
  unify.modules.gaming.home = {pkgs, ...}: {
    home.packages = with pkgs; [
      heroic
      prismlauncher
      r2modman
    ];
  };
}
