{lib, ...}: {
  flake.modules.nixos.laptop = {
    services.power-profiles-daemon.enable = lib.mkForce false;
    services.tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

        START_CHARGE_THRESH_BAT0 = 70;
        STOP_CHARGE_THRESH_BAT0 = 85;
      };
    };
  };

  flake.modules.nixos.gaming = {config, ...}: {
    services.tlp.settings = lib.mkIf config.services.tlp.enable {
      TLP_DEFAULT_MODE = "AC";
      TLP_PERSISTENT_DEFAULT = 1;
    };
  };
}
