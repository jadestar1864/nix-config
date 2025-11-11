{
  inputs,
  lib,
  ...
}: {
  flake.modules.homeManager.gui = {pkgs, ...}: {
    home.packages = [pkgs.libnotify];
    programs.zsh = {
      initContent = lib.mkAfter ''
        AUTO_NOTIFY_IGNORE+=("hx" "yazi" "jj")
      '';
      plugins = [
        {
          name = "auto-notify";
          src = inputs.zsh-auto-notify;
        }
      ];
    };
  };
}
