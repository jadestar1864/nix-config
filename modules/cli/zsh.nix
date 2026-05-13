{
  den,
  lib,
  ...
}: {
  den.aspects.devops = {
    includes = [(den.batteries.user-shell "zsh")];
    homeManager = {pkgs, ...}: {
      programs.yazi.settings = {
        open.rules = [
          {
            mime = "inode/directory";
            use = "zsh-dir";
          }
        ];

        opener.zsh-dir = [
          (let
            zsh = lib.getExe pkgs.zsh;
          in {
            run = ''${zsh} -c "cd $0 && exec ${zsh}"'';
            block = true;
            desc = "Open directory in zsh";
          })
        ];
      };
    };
  };
}
