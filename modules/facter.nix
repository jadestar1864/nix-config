{
  den.default = {
    nixos.hardware.facter.detected.dhcp.enable = false;
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        nixos-facter
      ];
    };
  };
}
