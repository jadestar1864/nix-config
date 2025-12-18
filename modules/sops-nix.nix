{
  inputs,
  rootPath,
  ...
}: {
  unify = {
    nixos = {
      imports = [inputs.sops-nix.nixosModules.sops];
      sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    };
    modules.dev.home = {
      config,
      hostConfig,
      ...
    }: {
      imports = [inputs.sops-nix.homeManagerModules.sops];

      sops = {
        age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
        defaultSopsFile = "${rootPath}/secrets/${hostConfig.primaryUser.username}.yml";
      };
    };
  };
}
