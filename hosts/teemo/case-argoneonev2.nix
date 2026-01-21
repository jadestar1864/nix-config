{inputs, ...}: {
  unify.hosts.nixos.teemo.nixos = {pkgs, ...}: {
    services.hardware.argonone = {
      enable = true;
      package = pkgs.argononed.overrideAttrs {
        src = "${inputs.argononed}";
        # avoid direct /dev/vcio commands
        USE_SYSFS_TEMP = 1;
        patches = [
          "${inputs.argononed}/OS/nixos/patches/shutdown.patch"
        ];
      };
    };
  };
}
