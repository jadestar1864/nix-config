{
  den.aspects.devops.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.nix-output-monitor];
  };
}
