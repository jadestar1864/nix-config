{lib, ...}: {
  unify.nixos = {
    services.openssh = {
      settings = {
        LogLevel = "INFO";
        Ciphers = [
          "aes128-ctr"
          "aes192-ctr"
          "aes256-ctr"
          "aes128-cbc"
          "3des-cbc"
          "aes192-cbc"
          "aes256-cbc"
        ];
        Macs = [
          "hmac-sha2-512"
          "hmac-sha2-256"
          "hmac-sha1"
        ];
        PermitRootLogin = lib.mkDefault "no";
      };
      extraConfig = ''
        PermitEmptyPasswords no
        ClientAliveCountMax 0
        ClientAliveInterval 300
        PermitUserEnvironment no
        IgnoreRhosts yes
        HostbasedAuthentication no
        MaxAuthTries 4
      '';
    };
  };
}
