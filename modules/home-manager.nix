{
  inputs,
  lib,
  ...
}: {
  unify = {
    nixos = {hostConfig, ...}: {
      imports = [inputs.home-manager.nixosModules.home-manager];

      home-manager = {
        useGlobalPkgs = true;
        extraSpecialArgs.hasGlobalPkgs = true;
        # https://github.com/nix-community/home-manager/issues/6770
        #useUserPackages = true;

        users.${hostConfig.primaryUser.username}.imports = [
          (
            {osConfig, ...}: {
              home.stateVersion = lib.mkDefault osConfig.system.stateVersion;
            }
          )
        ];
      };
    };
    home = {hostConfig, ...}: {
      home = {
        username = hostConfig.primaryUser.username;
        homeDirectory = "/home/${hostConfig.primaryUser.username}";
      };
      programs.home-manager.enable = true;
    };
  };
}
