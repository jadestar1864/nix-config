{
  unify.hosts.nixos.teemo.nixos = {pkgs, ...}: {
    # Reference: https://git.eisfunke.com/config/nixos/-/blob/90b677e694dfccc079ce8d4d40b931082c9639d8/devices/amethyst.nix#L50
    hardware.deviceTree = let
      /*
      Pin the raspberrypifw package to an old version.

      - later versions bricked the devicetree so that HDMI wouldn't work anymore
      - due to some changes around HDMI and audio for the rpi5?
      - see: https://github.com/pftf/RPi4/issues/252
      - the uefi firmware rolled back to a version of the raspberrypi/firmware repo before those
        changes: https://github.com/pftf/RPi4/commit/6ba22a07bf19422c199dd801d3442319c04f5090
      - they pinned it to b49983637106e5fb33e2ae60d8c15a53187541e4, so I'm doing the same on the
        system level
      */
      raspberrypifw = pkgs.raspberrypifw.overrideAttrs {
        version = "pinned-2023.05.12";
        src = pkgs.fetchFromGitHub {
          owner = "raspberrypi";
          repo = "firmware";
          rev = "b49983637106e5fb33e2ae60d8c15a53187541e4";
          hash = "sha256-Ia+pUTl5MlFoYT4TrdAry0DsoBrs13rfTYx2vaxoKMw=";
        };
      };
    in {
      enable = true;
      # use the devicetree files from the official raspberrypi linux tree
      dtbSource = pkgs.device-tree_rpi.override {inherit raspberrypifw;};
      filter = "bcm2711-rpi-4-b.dtb";
      name = "broadcom/bcm2711-rpi-4-b.dtb";
      /*
      Devicetree overlays applied to the main devicetree.

      - these are applied during build, i.e. these are *not* passed separately to the bootloader
      - they're compiled in beforehand, the resulting single dtb file is then given to the bootloader
      - overlays are applied in the order they're in the list
      - the upstream overlays by raspberrypi are in the raspberrypifw package, see `upstreamOverlay`
      - these are documented in their repo: https://github.com/raspberrypi/linux/blob/rpi-6.12.y/arch/arm/boot/dts/overlays/README
      */
      overlays = let
        upstreamOverlay = name: raspberrypifw + /share/raspberrypi/boot/overlays/${name}.dtbo;
      in [
        # Fixes a bug experienced with rpi on the mainline kernel where only one CPU core would work.
        {
          name = "custom-enable-method";
          dtsText = ''
            /dts-v1/;
            /plugin/;

            / {
              compatible = "brcm,bcm2711";

              fragment@0 {
                target = <&cpus>;
                __overlay__ {
                  /delete-property/ enable-method;
                };
              };

              fragment@1 {
                target-path = "/";
                __overlay__ {
                  psci {
                    compatible = "arm,psci-1.0", "arm,psci-0.2";
                    method = "smc";
                  };
                };
              };

              fragment@2 {
                target = <&cpu0>;
                __overlay__ {
                  enable-method = "psci";
                  /delete-property/ cpu-release-addr;
                };
              };

              fragment@3 {
                target = <&cpu1>;
                __overlay__ {
                  enable-method = "psci";
                  /delete-property/ cpu-release-addr;
                };
              };

              fragment@4 {
                target = <&cpu2>;
                __overlay__ {
                  enable-method = "psci";
                  /delete-property/ cpu-release-addr;
                };
              };

              fragment@5 {
                target = <&cpu3>;
                __overlay__ {
                  enable-method = "psci";
                  /delete-property/ cpu-release-addr;
                };
              };

            };
          '';
        }
        /*
        This overlay comprises the vc4-kms-v3d-pi4 and dwc2 overlays for graphics and USB.

        - note that nixos-hardware uses the vc4-fkms-v3d-pi4 overlay instead
        - fkms (fake/firmware kernel mode setting) uses a feature in the firmware blob, proper kms
          implements mode setting itself
        - https://forums.raspberrypi.com/viewtopic.php?t=255478
        - the kms driver is newer, fkms is deprecated by upstream now
        */
        {
          name = "upstream-pi4";
          dtboFile = upstreamOverlay "upstream-pi4";
        }
      ];
    };
  };
}
