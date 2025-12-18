{
  unify.modules.dev.home = {
    programs.zsh = {
      autosuggestion.enable = true;
      initContent = ''
        bindkey '^[^M' autosuggest-execute
      '';
    };
  };
}
