{
  unify.modules.dev = {
    home = {
      config,
      pkgs,
      ...
    }: {
      sops.secrets = {
        "ssh_mma_github_rw_private_key" = {
          path = "${config.home.homeDirectory}/.ssh/id_mma_github_rw";
        };
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
            };
          "gh-mma" =
            defaults
            // {
              hostname = "github.com";
              user = "git";
              identitiesOnly = true;
              identityFile = config.sops.secrets."ssh_mma_github_rw_private_key".path;
            };
        };
      };
    };
  };
}
