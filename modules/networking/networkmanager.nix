{config, ...}: {
  flake.modules.nixos.pc = {
    networking.networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };

    users.users.${config.flake.meta.owner.username}.extraGroups = ["networkmanager"];
  };
}
