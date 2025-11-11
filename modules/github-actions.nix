{
  self,
  inputs,
  lib,
  ...
}: {
  flake.githubActions = inputs.nix-github-actions.lib.mkGithubMatrix {
    checks = lib.getAttrs ["x86_64-linux"] self.checks;
  };
}
