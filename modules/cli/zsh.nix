{
  config,
  lib,
  ...
}: {
  flake.modules = {
    nixos.base = {pkgs, ...}: {
      programs.zsh.enable = true;

      users.users.${config.flake.meta.owner.username}.shell = pkgs.zsh;
    };

    homeManager.base = {config, ...}: let
      zsh = lib.getExe config.programs.zsh.package;
    in {
      programs.zsh = {
        enable = true;
      };

      programs.yazi.settings = {
        open.rules = [
          {
            mime = "inode/directory";
            use = "zsh-dir";
          }
        ];

        opener.zsh-dir = [
          {
            run = ''${zsh} -c "cd $0 && exec ${zsh}"'';
            block = true;
            desc = "Open directory in zsh";
          }
        ];
      };
    };
  };
}
