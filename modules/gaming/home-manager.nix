{config, ...}: {
  flake.modules.nixos.gaming = {
    home-manager.users.${config.flake.meta.owner.username}.imports = [
      config.flake.modules.homeManager.gaming
    ];
  };
}
