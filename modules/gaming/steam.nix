{
  unify.modules.gaming.nixos = {
    programs.steam.enable = true;

    nixpkgs.allowedUnfreePackages = [
      "steam"
      "steam-original"
      "steam-run"
      "steam-unwrapped"
    ];
  };
}
