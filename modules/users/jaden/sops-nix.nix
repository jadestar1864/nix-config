{inputs, ...}: {
  den.aspects.jaden.homeManager = {config, ...}: {
    imports = [inputs.sops-nix.homeManagerModules.sops];

    sops = {
      age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      defaultSopsFile = ../../../secrets/users/jaden.yml;
    };
  };
}
