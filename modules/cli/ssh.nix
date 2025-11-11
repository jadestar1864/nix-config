{config, ...}: {
  flake.modules.nixos.dev = {
    home-manager.users.${config.flake.meta.owner.username}.imports = [
      ({pkgs, ...} @ homeArgs: {
        imports = [config.flake.modules.homeManager.sops-nix];

        sops.secrets = {
          "ssh_mma_github_rw_private_key" = {
            path = "${homeArgs.config.home.homeDirectory}/.ssh/id_mma_github_rw";
          };
        };

        # TODO: Not here, also awkward for non-pc systems
        home.sessionVariables = {
          SSH_AUTH_SOCK = "${homeArgs.config.home.homeDirectory}/.bitwarden-ssh-agent.sock";
        };

        programs.ssh = {
          enable = true;
          # Avoids infinite hang if control socket connection interrupted. ex: vpn goes down/up
          serverAliveCountMax = 3;
          serverAliveInterval = 5; # 3 * 5s
          matchBlocks = {
            "gh-js" = {
              hostname = "github.com";
              user = "git";
              identitiesOnly = true;
              identityFile = "${pkgs.writeText "id_gh_access.pub" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOh1Nd4Va9xCaEb4evaiclAiHMX6aX8+vXgf+AzlTfbe"}";
              identityAgent = "${homeArgs.config.home.homeDirectory}/.bitwarden-ssh-agent.sock";
            };
            "gh-mma" = {
              hostname = "github.com";
              user = "git";
              identitiesOnly = true;
              identityFile = homeArgs.config.sops.secrets."ssh_mma_github_rw_private_key".path;
            };
          };
        };
      })
    ];
  };
}
