{
  unify.modules.dev.nixos = {
    virtualisation.docker = {
      enable = false;
      rootless = {
        enable = true;
        daemon.settings = {
          dns = ["1.1.1.1" "9.9.9.9"];
        };
        setSocketVariable = true;
      };
    };
  };
}
