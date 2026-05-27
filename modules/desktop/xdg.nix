{
  den.default.homeManager = {config, ...}: {
    home.preferXdgDirectories = true;
    xdg = {
      enable = true;
      userDirs = {
        enable = true;
        setSessionVariables = true;
        createDirectories = true;
        music = "${config.home.homeDirectory}/Media/Music";
        pictures = "${config.home.homeDirectory}/Media/Pictures";
        videos = "${config.home.homeDirectory}/Media/Videos";
        # HACK: Using the options themselves with /var/empty is broken
        # publicshare = "/var/empty";
        # templates = "/var/empty";
        extraConfig = {
          PUBLICSHARE = "/var/empty";
          TEMPLATES = "/var/empty";
        };
      };
    };
  };
}
