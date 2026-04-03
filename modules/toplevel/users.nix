{rootPath, ...}: {
  unify = {
    nixos = {
      hostConfig,
      config,
      ...
    }: {
      sops.secrets.admin_password = {
        neededForUsers = true;
        sopsFile = "${rootPath}/secrets/hosts/shared.yml";
      };

      users = {
        groups = {
          ${hostConfig.primaryUser.username} = {};
          admin = {};
        };
        users = {
          ${hostConfig.primaryUser.username} = {
            isNormalUser = true;
            initialPassword = hostConfig.primaryUser.username;
            extraGroups = [
              "input"
            ];
          };
          admin = {
            isNormalUser = true;
            group = "admin";
            hashedPasswordFile = config.sops.secrets.admin_password.path;
            extraGroups = [
              "input"
            ];
          };
        };
      };
      nix.settings.trusted-users = ["admin"];
    };
  };
}
