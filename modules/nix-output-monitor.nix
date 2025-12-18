{
  unify.modules.dev.home = {pkgs, ...}: {
    home.packages = [pkgs.nix-output-monitor];
  };
}
