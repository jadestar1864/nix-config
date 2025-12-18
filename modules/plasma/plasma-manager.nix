{inputs, ...}: {
  unify.modules.desktop-plasma.home = {
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

      input = {
        touchpads = [
          {
            enable = true;
            naturalScroll = true;
            name = "ELAN0672:00 04F3:3187 Touchpad";
            productId = "3187";
            rightClickMethod = "twoFingers";
            scrollMethod = "twoFingers";
            twoFingerTap = "rightClick";
            vendorId = "04f3";
          }
        ];
      };
    };
  };
}
