{den, ...}: {
  den.aspects.pc = {
    includes = [(den.batteries.unfree ["spotify"])];
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        spotify
      ];
    };
  };
}
