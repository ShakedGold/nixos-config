{
  programs.nixvim = {
    plugins.better-escape = {
      enable = true;

      settings = {
        mappings = {
          t = {
            j = false;
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
