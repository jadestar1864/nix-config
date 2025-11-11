{
  flake.modules.nixos.pc = {pkgs, ...}: let
    mullvad-autostart = pkgs.makeAutostartItem {
      name = "mullvad-vpn";
      package = pkgs.mullvad-vpn;
    };
  in {
    services.mullvad-vpn = {
      enable = true;
      package = pkgs.mullvad-vpn;
    };

    environment.systemPackages = [mullvad-autostart];

    # Mullvad VPN currently only works if systemd-resolved is enabled
    services.resolved.enable = true;
    networking.networkmanager.dns = "systemd-resolved";
  };
}
