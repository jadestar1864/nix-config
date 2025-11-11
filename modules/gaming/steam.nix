{
  nixpkgs.allowedUnfreePackages = [
    "steam"
    "steam-original"
    "steam-run"
    "steam-unwrapped"
  ];

  flake.modules.nixos.gaming = {
    programs.steam.enable = true;
  };
}
