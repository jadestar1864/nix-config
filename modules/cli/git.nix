{
  unify = {
    nixos = {
      programs.git = {
        enable = true;
        config = {
          safe.directory = ["/etc/nixos"];
        };
      };
    };
    modules.dev.home = {hostConfig, ...}: {
      programs.git = {
        enable = true;
        settings = {
          user = {
            name = hostConfig.primaryUser.name;
            email = hostConfig.primaryUser.email;
          };
          init.defaultBranch = "main";
          url = {
            "https://github.com/" = {
              insteadOf = [
                "gh:"
                "github:"
              ];
            };
          };
        };
        signing = {
          format = "ssh";
          key = "key::ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGCTyTIHe2iEPYrxakHv66Mr9CkIC9MP27jcXpes13mO";
          signByDefault = true;
        };
      };
    };
  };
}
