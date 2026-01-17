{
  unify = {
    nixos = {
      hardware.facter.detected.dhcp.enable = false;
    };
    home = {pkgs, ...}: {
      home.packages = with pkgs; [nixos-facter];
    };
  };
}
