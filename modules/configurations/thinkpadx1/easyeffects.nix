{config, ...}: {
  configurations.nixos.thinkpadx1.module = {
    home-manager.users.${config.flake.meta.owner.username}.imports = [
      {
        services.easyeffects.preset = "Loudness+Autogain";
      }
    ];
  };
}
