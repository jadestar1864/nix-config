{
  unify.modules.pc.nixos = {hostConfig, ...}: {
    networking.networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };

    users.users.${hostConfig.primaryUser.username}.extraGroups = ["networkmanager"];
  };
}
