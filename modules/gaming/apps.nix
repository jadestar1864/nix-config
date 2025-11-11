{
  flake.modules.homeManager.gaming = {pkgs, ...}: {
    home.packages = with pkgs; [
      heroic
      prismlauncher
      r2modman
    ];
  };
}
