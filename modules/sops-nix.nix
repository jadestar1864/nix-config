{
  inputs,
  rootPath,
  ...
}: {
  unify = {
    nixos = {hostConfig, ...}: {
      imports = [inputs.sops-nix.nixosModules.sops];
      sops = {
        age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
        defaultSopsFile = "${rootPath}/secrets/hosts/${hostConfig.name}.yml";
      };
    };
    modules.dev.home = {
      config,
      hostConfig,
      ...
    }: {
      imports = [inputs.sops-nix.homeManagerModules.sops];

      sops = {
        age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
        defaultSopsFile = "${rootPath}/secrets/users/${hostConfig.primaryUser.username}.yml";
      };
    };
  };
}
