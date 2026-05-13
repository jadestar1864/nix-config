{den, ...}: {
  den.aspects.gaming = {
    nixos.programs.steam.enable = true;
    includes = [
      (den.batteries.unfree [
        "steam"
        "steam-original"
        "steam-run"
        "steam-unwrapped"
      ])
    ];
  };
}
