{
  programs.nixvim = {
    plugins.comment = {
      enable = true;

      settings.toggler = {
        block = "<leader>/";
        line = "<leader>/";
      };
    };
  };
}
