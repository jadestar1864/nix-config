{config, ...}: {
  flake.modules.nixos.desktop-plasma = {
    home-manager.users.${config.flake.meta.owner.username}.imports = [
      config.flake.modules.homeManager.desktop-plasma
    ];
  };
}
