{
  den.aspects.devops = {
    homeManager = {
      programs.jujutsu.enable = true;
      programs.jujutsu.settings = {
        ui = {
          editor = "hx";
          show-cryptographic-signatures = true;
        };
        aliases = {
          tug = ["bookmark" "move" "main" "--to" "@"];
          "tug-" = ["bookmark" "move" "main" "--to" "@-"];
        };
      };
    };
  };
}
