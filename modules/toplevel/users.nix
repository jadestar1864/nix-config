{
  unify = {
    nixos = {hostConfig, ...}: {
      users = {
        groups.${hostConfig.primaryUser.username} = {};
        users.${hostConfig.primaryUser.username} = {
          isNormalUser = true;
          initialPassword = hostConfig.primaryUser.username;
          extraGroups = [
            "input"
          ];
        };
      };
      # TODO: Create admin account to add here
      #nix.settings.trusted-users = [hostConfig.primaryUser.username];
    };
  };
}
