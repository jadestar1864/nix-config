{lib, ...}: {
  den.aspects = {
    devops.homeManager = {pkgs, ...}: {
      programs.gpg = {
        enable = true;
      };
      services.gpg-agent = {
        enable = true;
        enableScDaemon = true;
        pinentry.package = pkgs.pinentry-tty;
      };
    };
    pc.homeManager = {pkgs, ...}: {
      services.gpg-agent.pinentry.package = lib.mkForce pkgs.pinentry-qt;
    };
  };
}
