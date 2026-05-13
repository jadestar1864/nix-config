{lib, ...}: {
  den.aspects.devops.homeManager = {user, ...}:
    lib.optionalAttrs (user.name == "jaden") {
      programs.jujutsu.settings = {
        user = {
          name = "Jaden Nola";
          email = "proto@jadestar.dev";
        };
        signing = {
          backend = "ssh";
          behavior = "own";
          key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGCTyTIHe2iEPYrxakHv66Mr9CkIC9MP27jcXpes13mO";
        };
        git = {
          sign-on-push = true;
        };
      };
    };
}
