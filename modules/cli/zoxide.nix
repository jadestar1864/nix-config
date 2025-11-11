{
  flake.modules.homeManager.base = {
    programs.zoxide.enable = true;

    home.shellAliases = {
      cd = "z";
    };
  };
}
