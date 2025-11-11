{
  flake.modules.homeManager.base = {
    programs.yazi = {
      enable = true;
      settings = {
        mgr.show_hidden = true;
      };
      keymap = {
        mgr = {
          prepend_keymap = [
            {
              on = ["g" "e"];
              run = "arrow bot";
              desc = "Go to bottom";
            }
          ];
        };
      };
    };
  };
}
