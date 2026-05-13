{
  den.aspects.devops.homeManager = {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      config.global.warn_timeout = 0;
    };
    programs.git.ignores = [
      ".envrc"
      ".direnv"
    ];
  };
}
