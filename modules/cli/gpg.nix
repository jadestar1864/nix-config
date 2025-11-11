{
  config,
  lib,
  ...
}: {
  flake.modules.nixos.base = {
    home-manager.users.${config.flake.meta.owner.username}.imports = [
      ({pkgs, ...}: {
        programs.gpg = {
          enable = true;
          publicKeys = [
            {
              # TODO: Move public key file somewhere else
              source = ./pgp.asc;
              trust = 5;
            }
          ];
        };
        services.gpg-agent = {
          enable = true;
          enableScDaemon = true;
          pinentry.package = lib.mkDefault pkgs.pinentry-tty;
        };
      })
    ];
  };

  flake.modules.nixos.pc = {
    home-manager.users.${config.flake.meta.owner.username}.imports = [
      ({pkgs, ...}: {
        services.gpg-agent.pinentry.package = pkgs.pinentry-qt;
      })
    ];
  };
}
