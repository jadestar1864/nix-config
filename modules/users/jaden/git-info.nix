{lib, ...}: {
  den.aspects.devops.homeManager = {user, ...}:
    lib.optionalAttrs (user.name == "jaden") {
      programs.git = {
        settings.user = {
          name = "Jaden Nola";
          email = "proto@jadestar.dev";
        };
        signing = {
          format = "ssh";
          key = "key::ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGCTyTIHe2iEPYrxakHv66Mr9CkIC9MP27jcXpes13mO";
          signByDefault = true;
        };
      };
    };
}
