{
  den.aspects.pc.homeManager = {pkgs, ...}: {
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
            ../assets/base16_default_dark.toml
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

  den.aspects.pc.provides.plasma.homeManager = {
    programs.plasma.shortcuts = {
      "services/Alacritty.desktop" = {
        _launch = "Meta+Q";
      };
    };
  };
}
