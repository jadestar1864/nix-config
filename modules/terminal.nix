{
  flake.modules.homeManager.gui = {pkgs, ...}: {
    fonts.fontconfig.enable = true;
    home.packages = with pkgs; [
      nerd-fonts.departure-mono
      font-awesome
    ];

    programs.alacritty = {
      enable = true;
      settings = {
        general = {
          import = [
            ./base16_default_dark.toml
          ];
        };
        font = {
          normal = {
            family = "DepartureMono Nerd Font Mono";
            style = "Regular";
          };
        };
      };
    };
  };

  flake.modules.homeManager.desktop-plasma = {
    programs.plasma.shortcuts = {
      "services/Alacritty.desktop" = {
        _launch = "Meta+Q";
      };
    };
  };
}
