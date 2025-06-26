{
  programs.nixvim = {
    plugins.telescope = {
      enable = true;
    };

    keymaps = [
      {
        mode = "n",
        key = "<leader>f";
        options.silent = true;
        action = "<cmd>Telescope find_files<CR>";
      }
    ];
  };
}
