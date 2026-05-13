{
  den.aspects.pc.homeManager = {
    config,
    pkgs,
    ...
  }: {
    home.packages = [pkgs.bitwarden-desktop];
    home.sessionVariables = {
      SSH_AUTH_SOCK = "${config.home.homeDirectory}/.bitwarden-ssh-agent.sock";
    };
  };
}
