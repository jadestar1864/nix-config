{
  den.default = {
    nixos.programs.git = {
      enable = true;
      config = {
        safe.directory = ["/etc/nixos"];
      };
    };
    homeManager.programs.git = {
      enable = true;
      settings = {
        init.defaultBranch = "main";
        url = {
          "https://github.com/" = {
            insteadOf = [
              "gh:"
              "github:"
            ];
          };
        };
      };
    };
  };
}
