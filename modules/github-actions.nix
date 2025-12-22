{
  self,
  inputs,
  ...
}: {
  flake.githubActions = inputs.nix-github-actions.lib.mkGithubMatrix {
    inherit (self) checks;
  };
}
