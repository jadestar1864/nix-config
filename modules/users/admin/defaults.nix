{
  den.aspects.admin = {
    user = {config, ...}: {
      group = "admin";
      hashedPasswordFile = config.sops.secrets.admin_password.path;
      extraGroups = [
        "wheel"
        "systemd-journal"
        "input"
      ];
    };
    provides.to-hosts.nixos = {
      users.groups.admin = {};
      sops.secrets.admin_password = {
        neededForUsers = true;
        sopsFile = ../../../secrets/hosts/shared.yml;
      };
      nix.settings.trusted-users = ["admin"];
    };
  };
}
