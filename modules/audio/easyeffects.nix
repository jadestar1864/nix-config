{lib, ...}: {
  unify.modules.pc.home = {
    config,
    pkgs,
    ...
  }: let
    easyeffects-presets = pkgs.fetchFromGitHub {
      owner = "JackHack96";
      repo = "EasyEffects-Presets";
      rev = "069195c4e73d5ce94a87acb45903d18e05bffdcc";
      hash = "sha256-nXVtX0ju+Ckauo0o30Y+sfNZ/wrx3HXNCK05z7dLaFc=";
    };
  in {
    services.easyeffects = {
      enable = true;
      preset = lib.mkDefault "Perfect EQ";
    };

    # Make select presets available
    home.file = {
      "${config.xdg.configHome}/easyeffects/output/Loudness+Autogain.json".source = "${easyeffects-presets}/Loudness+Autogain.json";
      "${config.xdg.configHome}/easyeffects/output/Perfect EQ.json".source = "${easyeffects-presets}/Perfect EQ.json";
    };
  };
}
