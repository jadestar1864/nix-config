{
  lib,
  config,
  ...
}: {
  flake.checks =
    [
      "asrock"
      "dokja"
      "thinkpadx1"
    ]
    |> lib.flip lib.getAttrs config.flake.nixosConfigurations
    |> lib.mapAttrsToList (
      name: nixos: {
        ${nixos.config.nixpkgs.hostPlatform.system} = {
          "configurations/nixos/${name}" = nixos.config.system.build.toplevel;
        };
      }
    )
    |> lib.mkMerge;
}
