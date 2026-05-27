{
  den.aspects.pc.homeManager = {
    programs.yazi = {
      enable = true;
      shellWrapperName = "y";
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
