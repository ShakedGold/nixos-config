{
  programs.nixvim = {
    plugins.better-escape = {
      enable = true;

      settings = {
        mappings = {
          t = {
            j = {
              j = false;
              k = false;
            };
          };
          v = {
            j = {
              k = false;
            };
          };
        };
      };
    };
  };
}
