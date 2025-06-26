{
  programs.nixvim = {
    plugins.telescope = {
      enable = true;

      mappings = {
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
