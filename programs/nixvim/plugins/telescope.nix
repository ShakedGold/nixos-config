{
  programs.nixvim = {
    plugins.telescope = {
      enable = true;

      settings = {
        defaults = {
          file_ignore_patterns = [
            "^.git/"
            "^.mypy_cache/"
            "^__pycache__/"
            "^output/"
            "^data/"
            "%.ipynb"
          ];

          layout_config = {
            prompt_position = "top";
          };

          mappings = {
            # "<C-j>" = {
            #   __raw = "require('telescope.actions').move_selection_next";
            # };
            # "<C-k>" = {
            #   __raw = "require('telescope.actions').move_selection_previous";
            # };
          };
          set_env = {
            COLORTERM = "truecolor";
          };
          sorting_strategy = "ascending";
        };
      };
    };
  };
}
