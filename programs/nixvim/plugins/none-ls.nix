{
  programs.nixvim = {
    plugins.none-ls = {
      enable = true;

      sources.formatting = {
        alejandra.enable = true;
        stylelua.enable = true;
        clang_format.enable = true;

        # Python
        blackd.enable = true;
        isort.enable = true;
      };
    };
  };
}
