{inputs, ...}: {
  den.default.nixos = {host, ...}: {
    imports = [inputs.sops-nix.nixosModules.sops];
    sops = {
      age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      defaultSopsFile = ../secrets/hosts/${host.hostName}.yml;
    };
  };
}
