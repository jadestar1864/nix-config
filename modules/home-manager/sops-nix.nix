{
  inputs,
  config,
  rootPath,
  ...
}: {
  flake.modules.homeManager.sops-nix = homeArgs: {
    imports = [inputs.sops-nix.homeManagerModules.sops];

    sops = {
      age.keyFile = "${homeArgs.config.home.homeDirectory}/.config/sops/age/keys.txt";
      defaultSopsFile = "${rootPath}/secrets/${config.flake.meta.owner.username}.yml";
    };
  };
}
