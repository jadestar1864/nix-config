{lib, ...}:
with lib; {
  unify.options.nixConfigPath = mkOption {
    type = types.str;
    description = "Path to nix config on machine";
    default = "/etc/nixos";
  };
}
