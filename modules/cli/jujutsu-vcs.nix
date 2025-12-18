{
  unify.modules.dev.home = {hostConfig, ...}: {
    programs.jujutsu.enable = true;
    programs.jujutsu.settings = {
      user = {
        name = hostConfig.primaryUser.name;
        email = hostConfig.primaryUser.email;
      };

      ui = {
        editor = "hx";
        show-cryptographic-signatures = true;
      };

      signing = {
        backend = "ssh";
        behavior = "own";
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGCTyTIHe2iEPYrxakHv66Mr9CkIC9MP27jcXpes13mO";
      };

      aliases = {
        tug = ["bookmark" "move" "main" "--to" "@"];
        "tug-" = ["bookmark" "move" "main" "--to" "@-"];
      };

      git = {
        sign-on-push = true;
      };
    };
  };
}
