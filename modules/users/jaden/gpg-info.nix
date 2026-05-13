{lib, ...}: {
  den.aspects.devops.homeManager = {user, ...}:
    lib.optionalAttrs (user.name == "jaden") {
      programs.gpg.publicKeys = [
        {
          source = ../../assets/pgp.asc;
          trust = 5;
        }
      ];
    };
}
