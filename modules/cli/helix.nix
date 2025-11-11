{
  flake.modules.homeManager.base = {
    programs.helix = {
      enable = true;
      settings = {
        editor = {
          line-number = "absolute";
          indent-guides.render = true;
          cursor-shape = {
            normal = "block";
            insert = "bar";
            select = "underline";
          };
          bufferline = "multiple";
          color-modes = true;
        };
      };
    };
  };
}
