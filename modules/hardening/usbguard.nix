{lib, ...}: {
  flake.modules.nixos = {
    hardening = {
      services.usbguard.enable = true;
    };

    pc = {config, ...}: {
      services.usbguard.dbus.enable = config.services.usbguard.enable;
      security.polkit = lib.mkIf config.services.usbguard.enable {
        extraConfig = ''
          polkit.addRule(function(action, subject) {
            if ((action.id == "org.usbguard.Policy1.listRules" ||
                 action.id == "org.usbguard.Policy1.appendRule" ||
                 action.id == "org.usbguard.Policy1.removeRule" ||
                 action.id == "org.usbguard.Devices1.applyDevicePolicy" ||
                 action.id == "org.usbguard.Devices1.listDevices" ||
                 action.id == "org.usbguard1.getParameter" ||
                 action.id == "org.usbguard1.setParameter") &&
                 subject.active == true && subject.local == true &&
                 subject.isInGroup("wheel")) { return polkit.Result.YES; }
          });
        '';
      };
    };
  };
}
