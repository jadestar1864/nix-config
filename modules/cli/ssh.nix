{
  unify.modules.dev = {
    home = {pkgs, ...}: {
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
        };
      };
    };
  };
}
