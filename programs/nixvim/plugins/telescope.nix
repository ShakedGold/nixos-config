{
  programs.nixvim = {
    plugins.telescope = {
      enable = true;

      settings.mappings = {
        "<C-j>" = {
          __raw = "require('telescope.actions').move_selection_next";
        };
        "<C-k>" = {
          __raw = "require('telescope.actions').move_selection_previous";
        };
      };
    };
  };
}
