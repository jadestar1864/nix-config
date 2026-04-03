{
  unify.nixos = {hostConfig, ...}: {
    security.sudo-rs.enable = true;
    users.users.admin.extraGroups = [
      "wheel"
      "systemd-journal"
    ];
  };
}
