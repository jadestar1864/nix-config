{
  config,
  lib,
  ...
}: {
  flake.modules = {
    nixos.pc = {
      home-manager.users.${config.flake.meta.owner.username}.imports = [
        ({config, ...}: let
          zshExe = lib.getExe config.programs.zsh.package;
        in {
          programs.tmux.shell = zshExe;
        })
      ];
    };

    homeManager.gui = {
      programs.tmux = {
        enable = true;
        terminal = "xterm-256color";
        escapeTime = 0;
      };
      programs.zsh.initContent = lib.mkAfter ''
        AUTO_NOTIFY_IGNORE+=("tmux")
      '';
    };
  };
}
