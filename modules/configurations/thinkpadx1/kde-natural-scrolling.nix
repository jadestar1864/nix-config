{config, ...}: {
  configurations.nixos.thinkpadx1.module = {
    home-manager.users.${config.flake.meta.owner.username}.imports = [
      {
        programs.plasma.input = {
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
      }
    ];
  };
}
