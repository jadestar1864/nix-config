{den, ...}: {
  den.aspects.pc = {
    homeManager = {
      config,
      pkgs,
      ...
    }: {
      home.packages = [pkgs.bitwarden-desktop];
      home.sessionVariables = {
        SSH_AUTH_SOCK = "${config.home.homeDirectory}/.bitwarden-ssh-agent.sock";
      };
    };
    # TODO: Remove after bitwarden is updated
    # https://github.com/NixOS/nixpkgs/issues/526914
    # https://github.com/bitwarden/clients/pull/20448
    includes = [(den.batteries.insecure ["electron-39.8.10"])];
  };
}
