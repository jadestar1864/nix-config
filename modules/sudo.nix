{
  unify.nixos = {hostConfig, ...}: {
    security.sudo-rs.enable = true;
    users.users.${hostConfig.primaryUser.username}.extraGroups = [
      "wheel"
      "systemd-journal"
    ];
  };
}
