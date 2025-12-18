{
  unify.modules.pc = {
    nixos = {
      services.pipewire = {
        enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        pulse.enable = true;
        jack.enable = true;
      };
      security.rtkit.enable = true;
    };

    home = {pkgs, ...}: {
      home.packages = with pkgs; [
        pwvucontrol
        qpwgraph
      ];
    };
  };
}
