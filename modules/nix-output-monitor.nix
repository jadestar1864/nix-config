{
  flake.modules.nixos.base = {pkgs, ...}: {
    environment.systemPackages = [pkgs.nix-output-monitor];
  };
}
