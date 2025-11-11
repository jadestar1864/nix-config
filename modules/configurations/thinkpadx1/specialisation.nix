{config, ...}: {
  configurations.nixos.thinkpadx1.module = {
    specialisation = {
      gaming.configuration.imports = [
        config.flake.modules.nixos.gaming
      ];
    };
  };
}
