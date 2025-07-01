{
  programs.nixvim = {
    plugins.better-escape = {
      enable = true;

      settings = {
        mappings = {
          t = false;
        };
      };
    };
  };
}
