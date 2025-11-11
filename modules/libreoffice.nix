{
  flake.modules.nixos.pc = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      libreoffice-qt
      hunspell
      hunspellDicts.en_US
      hunspellDicts.es_MX
    ];
  };
}
