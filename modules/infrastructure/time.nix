{lib, ...}: let
  gos-chrony-conf = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/GrapheneOS/infrastructure/3691bd8e5140e918f5647e6d22da1c3e39cd93fe/etc/chrony.conf";
    sha256 = "sha256:0cfd5dwimiv4sadmknnc4l4zm7y49bmdnjdk7wc8wvnhfri3mick";
  };
in {
  unify = {
    modules.pc.nixos = {
      services = {
        automatic-timezoned.enable = true;
        geoclue2 = {
          # https://github.com/NixOS/nixpkgs/issues/68489#issuecomment-1484030107
          enableDemoAgent = lib.mkForce true;
          geoProviderUrl = "https://beacondb.net/v1/geolocate";
        };
      };
    };
    nixos = {
      config,
      pkgs,
      ...
    }: {
      services = {
        timesyncd.enable = false;
        chrony = {
          enable = true;

          # Disable 'rtcautotrim' so that 'rtcsync' can be used instead. Either
          # this or 'rtcsync' must be disabled to complete a successful rebuild,
          # or an error will be thrown due to these options conflicting with
          # eachother.
          enableRTCTrimming = false;

          # Initstepslew "is deprecated in favour of the makestep directive"
          # according to:
          # https://chrony-project.org/doc/4.6/chrony.conf.html#initstepslew.
          # The fetched chrony config already has makestep enabled, so
          # initstepslew is disabled (it is enabled by default).
          initstepslew.enabled = false;

          # Since servers are declared by the fetched chrony config, set the
          # NixOS option to [ ] to prevent the default values from interfering.
          servers = lib.mkForce [];

          # Enable seccomp filter for chronyd (-F 1) and reload server history on
          # restart (-r). The -r flag is added to match GrapheneOS's original
          # chronyd configuration.
          extraFlags = [
            "-F 1"
            "-r"
          ];

          # Borrowing chrony config from GrapheneOS sever infra.
          # Override the leapseclist path with the NixOS-compatible path to
          # leap-seconds.list using the tzdata package. This is necessary because
          # NixOS doesn't use standard FHS paths like /usr/share/zoneinfo.
          extraConfig = ''
            ${builtins.readFile gos-chrony-conf}
            leapseclist ${pkgs.tzdata}/share/zoneinfo/leap-seconds.list
          '';
        };
      };

      systemd.tmpfiles.settings."restrict-chrony-conf"."/var/lib/chrony/chrony.keys".z.mode = lib.mkIf config.services.chrony.enable "0400";
    };
  };
}
