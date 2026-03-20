{
  unify.home = {config, ...}: {
    home.preferXdgDirectories = true;
    xdg = {
      enable = true;
      userDirs = {
        enable = true;
        createDirectories = true;
        music = "${config.home.homeDirectory}/Media/Music";
        pictures = "${config.home.homeDirectory}/Media/Pictures";
        videos = "${config.home.homeDirectory}/Media/Videos";
        # HACK: Using the options themselves with /var/empty is broken
        # publicshare = "/var/empty";
        # templates = "/var/empty";
        extraConfig = {
          XDG_PUBLICSHARE_DIR = "/var/empty";
          XDG_TEMPLATES_DIR = "/var/empty";
        };
      };
    };
  };
}
