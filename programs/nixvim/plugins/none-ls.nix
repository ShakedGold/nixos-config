{
  programs.nixvim = {
    plugins.none-ls = {
      enable = true;

      sources.formatting = {
        alejandra.enable = true;
        stylua.enable = true;
        clang_format.enable = true;

        # Python
        black.enable = true;
        isort.enable = true;
      };
    };
  };
}
