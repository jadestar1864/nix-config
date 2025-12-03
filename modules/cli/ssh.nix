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
          enableDefaultConfig = false;
          matchBlocks = let
            defaults = {
              forwardAgent = false;
              addKeysToAgent = "no";
              compression = false;
              serverAliveInterval = 5;
              serverAliveCountMax = 3;
              hashKnownHosts = false;
              userKnownHostsFile = "~/.ssh/known_hosts";
              controlMaster = "no";
              controlPath = "~/.ssh/master-%r@%n:%p";
              controlPersist = "no";
            };
          in {
            "gh-js" =
              defaults
              // {
                hostname = "github.com";
                user = "git";
                identitiesOnly = true;
                identityFile = "${pkgs.writeText "id_gh_access.pub" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOh1Nd4Va9xCaEb4evaiclAiHMX6aX8+vXgf+AzlTfbe"}";
                identityAgent = "${homeArgs.config.home.homeDirectory}/.bitwarden-ssh-agent.sock";
              };
            "gh-mma" =
              defaults
              // {
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
