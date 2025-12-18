{lib, ...}: {
  unify.modules.dev = {
    nixos = {
      hostConfig,
      pkgs,
      ...
    }: {
      programs.zsh.enable = true;

      users.users.${hostConfig.primaryUser.username}.shell = pkgs.zsh;
    };

    home = {pkgs, ...}: let
      zsh = lib.getExe pkgs.zsh;
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
