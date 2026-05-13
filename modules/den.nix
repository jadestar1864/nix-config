{inputs, ...}: {
  imports = [inputs.den.flakeModule];
  den.schema.host.strict = true;
}
