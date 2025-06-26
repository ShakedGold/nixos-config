{
  programs.nixvim = {
    keymaps = [
      {
        mode = "n";
        key = "<leader>ff";
        options.silent = true;
        action = "<cmd>Telescope find_files<CR>";
      }
      {
        mode = "n";
        key = "<leader>fg";
        options.silent = true;
        action = "<cmd>Telescope live_grep<CR>";
      }
      {
        mode = "n";
        key = "<leader>e";
        options.silent = true;
        action = "<cmd>Neotree filesystem toggle<CR>";
      }
      {
        mode = "n";
        key = "<leader>w";
        options.silent = true;
        action = "<cmd>w<CR>";
      }
      {
        mode = "n";
        key = "<leader>q";
        options.silent = true;
        action = "<cmd>q<CR>";
      }
    ];
  };
}
