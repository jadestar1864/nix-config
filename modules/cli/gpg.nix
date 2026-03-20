{lib, ...}: {
  unify.modules = {
    dev.home = {pkgs, ...}: {
      programs.gpg = {
        enable = true;
        publicKeys = [
          {
            source = ../assets/pgp.asc;
            trust = 5;
          }
        ];
      };
      services.gpg-agent = {
        enable = true;
        enableScDaemon = true;
        pinentry.package = lib.mkDefault pkgs.pinentry-tty;
      };
    };
    pc.home = {pkgs, ...}: {
      services.gpg-agent.pinentry.package = pkgs.pinentry-qt;
    };
  };
}
