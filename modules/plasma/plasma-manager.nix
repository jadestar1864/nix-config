{inputs, ...}: {
  den.aspects.pc.provides.plasma.homeManager = {
    imports = [inputs.plasma-manager.homeModules.plasma-manager];
    programs.plasma = {
      enable = true;
      overrideConfig = true;

      workspace = {
        clickItemTo = "select";
        lookAndFeel = "org.kde.breezedark.desktop";
      };

      krunner = {
        shortcuts = {
          launch = "Meta+R";
        };
      };
    };
  };
}
