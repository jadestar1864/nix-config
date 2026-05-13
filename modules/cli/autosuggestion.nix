{
  den.aspects.devops.homeManager = {
    programs.zsh = {
      autosuggestion.enable = true;
      initContent = ''
        bindkey '^[^M' autosuggest-execute
      '';
    };
  };
}
