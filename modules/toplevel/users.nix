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
      nix.settings.trusted-users = [hostConfig.primaryUser.username];
    };
  };
}
