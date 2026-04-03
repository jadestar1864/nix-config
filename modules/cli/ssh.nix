{
  unify.modules.dev = {
    home = {
      config,
      pkgs,
      lib,
      ...
    }: {
      sops.secrets = {
        aesop_access_privatekey = {};
        dokja_access_privatekey = {};
        teemo_access_privatekey = {};
        aesop_admin_access_privatekey = {};
        dokja_admin_access_privatekey = {};
        teemo_admin_access_privatekey = {};
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
          "gl-js" =
            defaults
            // {
              hostname = "gitlab.com";
              user = "git";
              identitiesOnly = true;
              identityFile = "${pkgs.writeText "id_gl_access.pub" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFtnhwtWOLdPNs9htdbxz7Vr/h8hMPLgP00ApjPACWVb"}";
            };
          "dokja" =
            defaults
            // {
              hostname = lib.mkDefault "10.169.0.1";
              user = "jaden";
              identitiesOnly = true;
              identityFile = config.sops.secrets.dokja_access_privatekey.path;
            };
          "teemo" =
            defaults
            // {
              hostname = lib.mkDefault "10.169.0.3";
              user = "jaden";
              identitiesOnly = true;
              identityFile = config.sops.secrets.teemo_access_privatekey.path;
            };
          "aesop" =
            defaults
            // {
              hostname = lib.mkDefault "10.169.0.5";
              user = "jaden";
              identitiesOnly = true;
              identityFile = config.sops.secrets.aesop_access_privatekey.path;
            };
          "dokja-admin" =
            defaults
            // {
              hostname = config.programs.ssh.matchBlocks.dokja.data.hostname;
              user = "admin";
              identitiesOnly = true;
              identityFile = config.sops.secrets.dokja_admin_access_privatekey.path;
            };
          "teemo-admin" =
            defaults
            // {
              hostname = config.programs.ssh.matchBlocks.teemo.data.hostname;
              user = "admin";
              identitiesOnly = true;
              identityFile = config.sops.secrets.teemo_admin_access_privatekey.path;
            };
          "aesop-admin" =
            defaults
            // {
              hostname = config.programs.ssh.matchBlocks.aesop.data.hostname;
              user = "admin";
              identitiesOnly = true;
              identityFile = config.sops.secrets.aesop_admin_access_privatekey.path;
            };
        };
      };
    };
  };
}
