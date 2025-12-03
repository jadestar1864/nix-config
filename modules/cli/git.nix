{config, ...}: {
  flake.modules.nixos.base = {
    programs.git = {
      enable = true;
      config = {
        safe.directory = ["/etc/nixos"];
      };
    };

    home-manager.users.${config.flake.meta.owner.username}.imports = [
      {
        programs.git = {
          enable = true;
          settings = {
            user = {
              name = config.flake.meta.owner.name;
              email = config.flake.meta.owner.email;
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
      }
    ];
  };
}
