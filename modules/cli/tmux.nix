{lib, ...}: {
  unify.modules.dev.home = {pkgs, ...}: {
    programs.tmux = {
      enable = true;
      shell = "${pkgs.zsh}/bin/zsh";
      terminal = "xterm-256color";
      escapeTime = 0;
    };
    programs.fzf.tmux.enableShellIntegration = true;
    programs.zsh.initContent = lib.mkAfter ''
      AUTO_NOTIFY_IGNORE+=("tmux")
    '';
  };
}
