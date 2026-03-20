{
  unify.modules.pc = {
    nixos = {
      nixpkgs.allowedUnfreePackages = [
        "spotify"
      ];
    };
    home = {pkgs, ...}: {
      home.packages = with pkgs; [
        spotify
      ];
    };
  };
}
