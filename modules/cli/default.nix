{
  unify = {
    home = {
      programs.bash.enable = true;
    };
    modules.pc.home = {pkgs, ...}: {
      home.packages = with pkgs; [
        fastfetch
      ];

      programs.atuin.enable = true;
      programs.carapace.enable = true;
      programs.eza.enable = true;
      programs.fzf = {
        enable = true;
        defaultCommand = "fd --type f --strip-cwd-prefix";
      };
      programs.pay-respects.enable = true;
      programs.starship = {
        enable = true;
        settings = builtins.fromTOML (builtins.readFile ./gruvbox-rainbow.toml);
      };
    };
  };
}
